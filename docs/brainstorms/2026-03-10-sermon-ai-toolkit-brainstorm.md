# Sermon AI Toolkit Brainstorm

**Date:** 2026-03-10
**Status:** Ready for planning

## What We're Building

An AI-powered Toolkit for sermon recordings — a single dashboard page per recording that provides a suite of tools to help churches get more out of their sermon audio. The toolkit lives at `/admin/recordings/:id/toolkit` and is accessible via a "Toolkit" link from the recordings index/editor.

### Core Tools (v1)

#### 1. Transcription
- **Input:** Recording audio file (MP3)
- **AI:** OpenAI Whisper via Ruby LLM
- **Output:** Full text transcript with timestamps
- **Notes:** This is the foundation — most other tools depend on having a transcript first. Run as a background job. Store result in ToolkitResult.

#### 2. Content Generation (depends on transcript)
- **Summary** — 2-3 paragraph overview of the sermon's key points
- **Study Guide** — Discussion questions, key scripture references, application points
- **Newsletter/Article** — Substack-style writeup suitable for email or blog
- **Input:** Transcript text
- **AI:** OpenAI GPT-4o via Ruby LLM
- **Output:** Formatted text (Markdown)

#### 3. Speaker Coaching (depends on transcript)
- **Filler Word Analysis** — Count "um", "uh", "like", "you know", etc.
- **Pace/Timing Notes** — Words per minute, longest pauses
- **Style Suggestions** — Constructive tips on delivery, clarity, structure
- **Repetition Detection** — Phrases or ideas repeated excessively
- **Input:** Transcript text
- **AI:** GPT-4o for style analysis; filler word counting can be done in Ruby
- **Output:** Structured coaching report

#### 4. Handwriting Worksheet Generator (standalone — no transcript needed)
- **Input:** User types a Bible verse or phrase
- **Output:** Printable HTML page using dotted tracing font (KG Primary Dots style)
- **Approach:** Pure HTML/CSS with `@font-face` dotted font, print-optimized styles. Based on vibes.nathancolgate.com/001 pattern.
- **Features:**
  - Configurable repetition count
  - Size options (large/medium/small for different ages)
  - Print-optimized layout (hides UI, letter-size margins)
  - No AI needed — just font rendering + print CSS
- **Notes:** This is the one tool that doesn't need AI or a transcript. Fun, practical, and instantly usable.

### Future Tools (v2+)
- **Multi-sermon book/study guide** — Select multiple recordings, generate a cohesive print-on-demand booklet

## Why This Approach

### Single Dashboard per Recording
- All tools in one place — a "command center" for each recording
- Easy to see what's been generated, what's in progress, what's available
- Avoids navigation overhead of separate pages per tool
- Natural grouping: tools that depend on transcript show as locked/unavailable until transcript exists

### ToolkitResult Model
- Clean polymorphic storage: `tool_type` (enum), `status`, `output` (text), `metadata` (JSON)
- Belongs to Recording
- Tracks background job status: `queued → processing → completed / failed`
- Easy to query: "has this recording been transcribed?"
- Supports re-running tools (new result replaces old)

### OpenAI via Ruby LLM
- Single provider, single API key
- Whisper for transcription (best-in-class audio model)
- GPT-4o for all text generation tasks
- Ruby LLM gem provides clean Ruby interface

### Background Jobs via Solid Queue
- All AI operations run as background jobs (transcription can take 30+ seconds, text generation 10-20 seconds)
- Solid Queue is already configured in the project (solid_queue gem in Gemfile)
- Mount Solid Queue dashboard at `/admin/jobs` (behind admin auth)
- Custom Turbo-based status UX on the toolkit dashboard — something sweet, not just a spinner

### Handwriting Worksheets via Dotted Font
- No AI cost, no API dependency
- Dotted/tracing font approach (KG Primary Dots or similar)
- Pure HTML/CSS with print media queries
- Instant generation, no background job needed
- User controls: text input, repetition count, size selector

## Key Decisions

1. **Single dashboard UX** — One toolkit page per recording with all tools visible
2. **ToolkitResult model** — Dedicated model for AI outputs, not reusing Documents
3. **OpenAI as sole provider** — Whisper + GPT-4o, one API key
4. **Transcript is the foundation** — Most tools require it; generate it first, then unlock dependent tools
5. **Solid Queue for background jobs** — Already in Gemfile, SQLite-backed, fits the stack
6. **Custom job status UX** — Turbo-powered progress/status component (details TBD in planning)
7. **Handwriting worksheets use dotted font + HTML/CSS** — No AI needed, print-optimized
8. **Multi-sermon features deferred** — Get single-recording tools solid first
9. **User-provided API key required** — Each church/admin provides their own OpenAI API key. AI tools are gated behind API key setup. Handwriting worksheets work without a key since they don't use AI.

## Open Questions

1. **Job status UX details** — User wants a "super sweet" component. Exact design TBD during planning/implementation. Will use Turbo (frames/streams) for updates.
2. **Dotted font licensing** — KG Primary Dots may require a license. Need to find a free/open alternative or confirm licensing.
3. **API key storage** — Where to store the API key? Rails credentials, a Setting model, or encrypted column on the church/account? Needs to be secure and editable by admins.
4. **API cost management** — Should we show estimated cost before running a tool? Rate limiting?
5. **Transcript editing** — Should users be able to edit/correct the transcript before feeding it to other tools?
6. **Output formats** — Markdown rendering in the UI? Copy-to-clipboard? Export as PDF/DOCX?
7. **Prompt engineering** — The quality of summaries, study guides, etc. depends heavily on prompts. Plan to iterate on these.


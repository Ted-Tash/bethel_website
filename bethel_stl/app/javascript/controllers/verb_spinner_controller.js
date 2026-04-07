import { Controller } from "@hotwired/stimulus"

const VERBS = [
  "Accomplishing", "Actioning", "Actualizing", "Architecting", "Baking", "Beaming",
  "Befuddling", "Bloviating", "Boogieing", "Boondoggling", "Booping", "Bootstrapping",
  "Brewing", "Burrowing", "Calculating", "Canoodling", "Caramelizing", "Cascading",
  "Catapulting", "Cerebrating", "Channeling", "Choreographing", "Churning", "Clauding",
  "Coalescing", "Cogitating", "Combobulating", "Composing", "Computing", "Concocting",
  "Considering", "Contemplating", "Cooking", "Crafting", "Creating", "Crunching",
  "Crystallizing", "Cultivating", "Deciphering", "Deliberating", "Determining",
  "Discombobulating", "Doing", "Doodling", "Drizzling", "Ebbing", "Effecting",
  "Elucidating", "Embellishing", "Enchanting", "Envisioning", "Evaporating",
  "Fermenting", "Finagling", "Flibbertigibbeting", "Flowing", "Flummoxing",
  "Fluttering", "Forging", "Forming", "Frolicking", "Frosting", "Gallivanting",
  "Galloping", "Garnishing", "Generating", "Germinating", "Gitifying", "Grooving",
  "Gusting", "Harmonizing", "Hashing", "Hatching", "Herding", "Honking",
  "Hullaballooing", "Hyperspacing", "Ideating", "Imagining", "Improvising",
  "Incubating", "Inferring", "Infusing", "Ionizing", "Jitterbugging", "Julienning",
  "Kneading", "Leavening", "Levitating", "Lollygagging", "Manifesting", "Marinating",
  "Meandering", "Metamorphosing", "Misting", "Moonwalking", "Moseying", "Mulling",
  "Musing", "Mustering", "Nebulizing", "Nesting", "Noodling", "Nucleating", "Orbiting",
  "Orchestrating", "Osmosing", "Perambulating", "Percolating", "Perusing",
  "Philosophising", "Photosynthesizing", "Pollinating", "Pondering", "Pontificating",
  "Pouncing", "Precipitating", "Prestidigitating", "Processing", "Proofing",
  "Propagating", "Puttering", "Puzzling", "Quantumizing", "Razzmatazzing",
  "Recombobulating", "Reticulating", "Roosting", "Ruminating", "Scampering",
  "Schlepping", "Scurrying", "Seasoning", "Shenaniganing", "Shimmying", "Simmering",
  "Skedaddling", "Sketching", "Slithering", "Smooshing", "Spelunking", "Spinning",
  "Sprouting", "Stewing", "Sublimating", "Swirling", "Swooping", "Symbioting",
  "Synthesizing", "Tempering", "Thinking", "Thundering", "Tinkering", "Tomfoolering",
  "Transfiguring", "Transmuting", "Twisting", "Undulating", "Unfurling", "Unravelling",
  "Vibing", "Waddling", "Wandering", "Warping", "Whatchamacalliting", "Whirlpooling",
  "Whirring", "Whisking", "Wibbling", "Working", "Wrangling", "Zesting", "Zigzagging"
]

export default class extends Controller {
  static targets = ["word", "message"]
  static values = {
    message: { type: String, default: "Hang tight — these requests take a while to complete. We are working as fast as we can, thanks for being patient. This window will automatically update when the request is complete, no need to refresh." }
  }

  connect() {
    this.shuffled = this.shuffle([...VERBS])
    this.index = 0
    this.wordTarget.textContent = this.shuffled[this.index]
    this.wordTarget.classList.add("verb-spinner-enter")

    this.interval = setInterval(() => this.next(), 2000)

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = this.messageValue
    }
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  next() {
    const el = this.wordTarget

    // Exit: ripple out
    el.classList.remove("verb-spinner-enter")
    el.classList.add("verb-spinner-exit")

    setTimeout(() => {
      this.index = (this.index + 1) % this.shuffled.length
      el.textContent = this.shuffled[this.index]

      // Enter: ripple in
      el.classList.remove("verb-spinner-exit")
      el.classList.add("verb-spinner-enter")
    }, 400)
  }

  shuffle(arr) {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]]
    }
    return arr
  }
}

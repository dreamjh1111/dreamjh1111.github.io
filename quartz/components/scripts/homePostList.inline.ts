const storageKey = "home-post-list-view"

document.addEventListener("nav", () => {
  const lists = document.querySelectorAll<HTMLElement>(".home-post-list")

  for (const list of lists) {
    const buttons = list.querySelectorAll<HTMLButtonElement>("[data-home-view]")

    const applyView = (view: string) => {
      const nextView = view === "grid" ? "grid" : "list"
      list.dataset.view = nextView
      localStorage.setItem(storageKey, nextView)

      buttons.forEach((button) => {
        button.setAttribute("aria-pressed", String(button.dataset.homeView === nextView))
      })
    }

    const initialView = localStorage.getItem(storageKey) ?? list.dataset.view ?? "list"
    applyView(initialView)

    buttons.forEach((button) => {
      const onClick = () => applyView(button.dataset.homeView ?? "list")
      button.addEventListener("click", onClick)
      window.addCleanup(() => button.removeEventListener("click", onClick))
    })
  }
})

const mobileTitleQuery = window.matchMedia("(max-width: 800px)")

function fitPageTitle(title: HTMLElement) {
  const link = title.querySelector("a") as HTMLElement | null
  if (!link) return

  if (!mobileTitleQuery.matches) {
    title.style.removeProperty("--page-title-mobile-size")
    return
  }

  const availableWidth = Math.floor(title.getBoundingClientRect().width)
  if (availableWidth <= 0) return

  const computedStyle = window.getComputedStyle(title)
  const maxSize = parseFloat(computedStyle.fontSize) || 28
  const minSize = 13

  let low = minSize
  let high = maxSize
  let best = minSize

  while (low <= high) {
    const mid = Math.floor((low + high) / 2)
    title.style.setProperty("--page-title-mobile-size", `${mid}px`)

    if (link.scrollWidth <= availableWidth) {
      best = mid
      low = mid + 1
    } else {
      high = mid - 1
    }
  }

  title.style.setProperty("--page-title-mobile-size", `${best}px`)
}

document.addEventListener("nav", async () => {
  const titles = document.querySelectorAll<HTMLElement>(".sidebar.left > .page-title")

  const fitAll = () => titles.forEach((title) => fitPageTitle(title))

  fitAll()

  const onResize = () => fitAll()
  window.addEventListener("resize", onResize)
  window.addCleanup(() => window.removeEventListener("resize", onResize))

  if ("ResizeObserver" in window) {
    const observer = new ResizeObserver(() => fitAll())
    titles.forEach((title) => observer.observe(title))
    window.addCleanup(() => observer.disconnect())
  }

  if (document.fonts?.ready) {
    await document.fonts.ready
    fitAll()
  }
})

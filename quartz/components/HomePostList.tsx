import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { FullSlug, isFolderPath, isRelativeURL, joinSegments, resolveRelative } from "../util/path"
import { QuartzPluginData } from "../plugins/vfile"
import style from "./styles/homePostList.scss"
// @ts-ignore
import script from "./scripts/homePostList.inline"
import { Date as DateComponent } from "./Date"
import { i18n } from "../i18n"
import { classNames } from "../util/lang"
import { Element, Root } from "hast"
import { SortFn } from "./PageList"

interface Options {
  title?: string
  limit?: number
  filter: (f: QuartzPluginData) => boolean
  sort: (f1: QuartzPluginData, f2: QuartzPluginData) => number
}

const defaultFilter = (file: QuartzPluginData) => {
  const slug = file.slug ?? ""
  return slug !== "" && slug !== "404" && !slug.startsWith("tags/") && !isFolderPath(slug)
}

function getFrontmatterDate(page: QuartzPluginData): Date | undefined {
  const rawDate = page.frontmatter?.date
  if (typeof rawDate !== "string" && !(rawDate instanceof Date)) {
    return undefined
  }

  const parsedDate = new globalThis.Date(rawDate)
  return Number.isNaN(parsedDate.getTime()) ? undefined : parsedDate
}

const byFrontmatterDate: SortFn = (f1, f2) => {
  const f1Date = getFrontmatterDate(f1)
  const f2Date = getFrontmatterDate(f2)

  if (f1Date && f2Date) {
    return f2Date.getTime() - f1Date.getTime()
  }

  if (f1Date && !f2Date) {
    return -1
  }

  if (!f1Date && f2Date) {
    return 1
  }

  const f1Title = f1.frontmatter?.title.toLowerCase() ?? ""
  const f2Title = f2.frontmatter?.title.toLowerCase() ?? ""
  return f1Title.localeCompare(f2Title)
}

const defaultOptions = (): Options => ({
  title: "전체 글",
  filter: defaultFilter,
  sort: byFrontmatterDate,
})

function findFirstImageSrc(node?: Root | Element): string | undefined {
  if (!node || !("children" in node) || !Array.isArray(node.children)) {
    return undefined
  }

  for (const child of node.children) {
    if (child.type !== "element") continue

    if (child.tagName === "img") {
      const src = child.properties?.src
      if (typeof src === "string" && src.length > 0) {
        return src
      }
    }

    const nestedSrc = findFirstImageSrc(child)
    if (nestedSrc) {
      return nestedSrc
    }
  }

  return undefined
}

function normalizePreviewImageSrc(
  src: string,
  currentSlug: FullSlug,
  targetSlug: FullSlug,
): string {
  if (isRelativeURL(src)) {
    return joinSegments(resolveRelative(currentSlug, targetSlug), "..", src)
  }

  return src
}

function getPreviewImage(page: QuartzPluginData, currentSlug: FullSlug): string | undefined {
  const pageSlug = page.slug
  if (!pageSlug) return undefined

  const src = page.frontmatter?.socialImage ?? findFirstImageSrc(page.htmlAst as Root | undefined)

  if (!src || typeof src !== "string") {
    return undefined
  }

  return normalizePreviewImageSrc(src, currentSlug, pageSlug)
}

export default ((userOpts?: Partial<Options>) => {
  const HomePostList: QuartzComponent = ({
    allFiles,
    fileData,
    displayClass,
    cfg,
  }: QuartzComponentProps) => {
    const defaults = defaultOptions()
    const opts = {
      ...defaults,
      ...userOpts,
      title: userOpts?.title ?? defaults.title,
      filter: userOpts?.filter ?? defaults.filter,
      sort: userOpts?.sort ?? defaults.sort,
    }
    const pages = allFiles.filter(opts.filter).sort(opts.sort)
    const visiblePages = opts.limit ? pages.slice(0, opts.limit) : pages
    const homeSlug = fileData.slug as FullSlug

    return (
      <section class={classNames(displayClass, "home-post-list")} data-view="list">
        <div class="home-post-list-header">
          <h2>{opts.title}</h2>
          <div class="home-post-list-actions" role="group" aria-label="목록 보기 방식">
            <button
              type="button"
              class="home-post-list-toggle"
              data-home-view="grid"
              aria-label="블록형으로 보기"
              aria-pressed="false"
            >
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <rect x="4" y="4" width="6" height="6" rx="1"></rect>
                <rect x="14" y="4" width="6" height="6" rx="1"></rect>
                <rect x="4" y="14" width="6" height="6" rx="1"></rect>
                <rect x="14" y="14" width="6" height="6" rx="1"></rect>
              </svg>
            </button>
            <button
              type="button"
              class="home-post-list-toggle"
              data-home-view="list"
              aria-label="리스트형으로 보기"
              aria-pressed="true"
            >
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M5 7h14"></path>
                <path d="M5 12h14"></path>
                <path d="M5 17h14"></path>
              </svg>
            </button>
          </div>
        </div>
        <div class="home-post-list-grid">
          {visiblePages.map((page) => {
            if (!page.slug) return null

            const title = page.frontmatter?.title ?? i18n(cfg.locale).propertyDefaults.title
            const description = page.description?.trim()
            const showDescription = Boolean(description) && !isFolderPath(page.slug)
            const tags = page.frontmatter?.tags ?? []
            const href = resolveRelative(homeSlug, page.slug)
            const previewImage = getPreviewImage(page, homeSlug)
            const displayDate = getFrontmatterDate(page)

            return (
              <article class="home-post-card" data-has-image={previewImage ? "true" : "false"}>
                <div class="home-post-card-main">
                  {displayDate && (
                    <p class="home-post-card-date">
                      <DateComponent date={displayDate} locale={cfg.locale} />
                    </p>
                  )}
                  <h3>
                    <a href={href} class="internal">
                      {title}
                    </a>
                  </h3>
                  {showDescription && <p class="home-post-card-description">{description}</p>}
                  {tags.length > 0 && (
                    <ul class="tags">
                      {tags.map((tag) => (
                        <li>
                          <a
                            class="internal tag-link"
                            href={resolveRelative(homeSlug, `tags/${tag}` as FullSlug)}
                          >
                            {tag}
                          </a>
                        </li>
                      ))}
                    </ul>
                  )}
                  <p class="home-post-card-more">
                    <a href={href} class="internal">
                      더보기
                    </a>
                  </p>
                </div>
                {previewImage && (
                  <a
                    href={href}
                    class="internal home-post-card-media"
                    tabIndex={-1}
                    aria-hidden="true"
                  >
                    <img src={previewImage} alt="" loading="lazy" />
                  </a>
                )}
              </article>
            )
          })}
        </div>
      </section>
    )
  }

  HomePostList.afterDOMLoaded = script
  HomePostList.css = style
  return HomePostList
}) satisfies QuartzComponentConstructor

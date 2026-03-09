import { pathToRoot } from "../util/path"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"
import { i18n } from "../i18n"
// @ts-ignore
import script from "./scripts/pageTitle.inline"

const PageTitle: QuartzComponent = ({ fileData, cfg, displayClass }: QuartzComponentProps) => {
  const title = cfg?.pageTitle ?? i18n(cfg.locale).propertyDefaults.title
  const baseDir = pathToRoot(fileData.slug!)
  return (
    <h2 class={classNames(displayClass, "page-title")}>
      <a href={baseDir}>{title}</a>
    </h2>
  )
}

PageTitle.css = `
.page-title {
  font-size: 1.75rem;
  margin: 0;
  font-family: var(--titleFont);
  min-width: 0;
  line-height: 1.1;
}

.page-title a {
  display: block;
  min-width: 0;
}

@media all and (max-width: 800px) {
  .page-title {
    font-size: var(--page-title-mobile-size, 1.75rem);
  }

  .page-title a {
    white-space: nowrap;
  }
}
`

PageTitle.afterDOMLoaded = script

export default (() => PageTitle) satisfies QuartzComponentConstructor

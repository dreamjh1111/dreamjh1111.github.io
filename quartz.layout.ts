import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"

const giscusConfig = {
  repo: "dreamjh1111/dreamjh1111.github.io" as const,
  // Replace these two IDs with values from https://giscus.app
  repoId: "R_kgDORfDPig",
  category: "Announcements",
  categoryId: "DIC_kwDORfDPis4C34mu",
  lang: "ko",
}

export const sharedPageComponents: SharedLayout = {
  head: Component.Head(),
  header: [],
  afterBody: [
    Component.ConditionalRender({
      component: Component.Comments({
        provider: "giscus",
        options: {
          repo: giscusConfig.repo,
          repoId: giscusConfig.repoId,
          category: giscusConfig.category,
          categoryId: giscusConfig.categoryId,
          lang: giscusConfig.lang,
          mapping: "pathname",
          strict: false,
          reactionsEnabled: true,
          inputPosition: "bottom",
        },
      }),
      condition: (page) =>
        page.fileData.slug !== "index" &&
        page.fileData.slug !== "404" &&
        !page.fileData.slug.startsWith("tags/") &&
        !page.fileData.slug.endsWith("/index"),
    }),
  ],
  footer: Component.Footer({
    links: {
      GitHub: "https://github.com/dreamjh1111/dreamjh1111.github.io",
    },
  }),
}

export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.ConditionalRender({
      component: Component.Breadcrumbs(),
      condition: (page) => page.fileData.slug !== "index",
    }),
    Component.ArticleTitle(),
    Component.ContentMeta(),
    Component.TableOfContents(),
    Component.TagList(),
  ],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Flex({
      components: [
        {
          Component: Component.Search(),
          grow: true,
        },
        { Component: Component.Darkmode() },
        { Component: Component.ReaderMode() },
      ],
    }),
    Component.Explorer(),
  ],
  right: [
    Component.Graph(),
    Component.TableOfContents(),
    Component.Backlinks(),
  ],
}

export const defaultListPageLayout: PageLayout = {
  beforeBody: [Component.Breadcrumbs(), Component.ArticleTitle(), Component.ContentMeta()],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Flex({
      components: [
        {
          Component: Component.Search(),
          grow: true,
        },
        { Component: Component.Darkmode() },
      ],
    }),
    Component.Explorer(),
  ],
  right: [],
}

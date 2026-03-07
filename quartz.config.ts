import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"
import { QuartzTransformerPlugin } from "./quartz/plugins/types"

const DefaultDarkMode: QuartzTransformerPlugin = () => ({
  name: "DefaultDarkMode",
  externalResources() {
    return {
      js: [
        {
          loadTime: "beforeDOMReady",
          contentType: "inline",
          spaPreserve: true,
          script: `if (localStorage.getItem("theme") == null) {
  localStorage.setItem("theme", "dark")
  document.documentElement.setAttribute("saved-theme", "dark")
}`,
        },
      ],
    }
  },
})

const config: QuartzConfig = {
  configuration: {
    pageTitle: "Jayden Tech Blog",
    pageTitleSuffix: " | Jayden Tech Blog",
    enableSPA: true,
    enablePopovers: true,
    analytics: null,
    adsense: {
      enabled: true,
      publisherId: "ca-pub-3857371928558595",
      adsTxtEnabled: true,
      adsTxtLines: ["google.com, pub-3857371928558595, DIRECT, f08c47fec0942fa0"],
    },
    locale: "ko-KR",
    baseUrl: "dreamjh1111.github.io",
    ignorePatterns: ["private", "_templates", ".obsidian"],
    defaultDateType: "modified",
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Noto Sans KR",
        body: "Noto Sans KR",
        code: "IBM Plex Mono",
      },
      colors: {
        lightMode: {
          light: "#faf8f8",
          lightgray: "#e5e5e5",
          gray: "#b8b8b8",
          darkgray: "#4e4e4e",
          dark: "#2b2b2b",
          secondary: "#284b63",
          tertiary: "#84a59d",
          highlight: "rgba(143, 159, 169, 0.15)",
          textHighlight: "#fff23688",
        },
        darkMode: {
          light: "#161618",
          lightgray: "#393639",
          gray: "#646464",
          darkgray: "#d4d4d4",
          dark: "#ebebec",
          secondary: "#7b97aa",
          tertiary: "#84a59d",
          highlight: "rgba(143, 159, 169, 0.15)",
          textHighlight: "#b3aa0288",
        },
      },
    },
  },
  plugins: {
    transformers: [
      DefaultDarkMode(),
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "filesystem"],
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "mathjax" }),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.Favicon(),
      Plugin.NotFoundPage(),
      Plugin.CustomOgImages(),
      Plugin.RobotsTxt(),
      Plugin.AdSense(),
      Plugin.SearchConsoleMetaTag({
        enabled: true,
        content: "7Tv3XXa4ezsMblmlnxzSFaybQAqbyR7-mXtKUcJBAtU",
      }),
    ],
  },
}

export default config

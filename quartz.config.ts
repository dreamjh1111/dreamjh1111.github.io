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
  localStorage.setItem("theme", "light")
  document.documentElement.setAttribute("saved-theme", "light")
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
          light: "#f5f5f5",
          lightgray: "#e5e7eb",
          gray: "#cbd5e1",
          darkgray: "#475569",
          dark: "#111827",
          secondary: "#2563eb",
          tertiary: "#3b82f6",
          highlight: "rgba(37, 99, 235, 0.1)",
          textHighlight: "#ffe06666",
        },
        darkMode: {
          light: "#1e1e1e",
          lightgray: "#2f343b",
          gray: "#4b5563",
          darkgray: "#cbd5e1",
          dark: "#f8fafc",
          secondary: "#7cb4ff",
          tertiary: "#a5cfff",
          highlight: "rgba(124, 180, 255, 0.14)",
          textHighlight: "#ffd43b55",
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

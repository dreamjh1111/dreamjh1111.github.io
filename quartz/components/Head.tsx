import { i18n } from "../i18n"
import { FullSlug, getFileExtension, joinSegments, pathToRoot, simplifySlug } from "../util/path"
import { CSSResourceToStyleElement, JSResourceToScriptElement } from "../util/resources"
import { googleFontHref, googleFontSubsetHref } from "../util/theme"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { unescapeHTML } from "../util/escape"
import { CustomOgImagesEmitterName } from "../plugins/emitters/ogImage"
import { getDate } from "./Date"

export default (() => {
  const Head: QuartzComponent = ({
    cfg,
    fileData,
    externalResources,
    ctx,
  }: QuartzComponentProps) => {
    const titleSuffix = cfg.pageTitleSuffix ?? ""
    const title =
      (fileData.frontmatter?.title ?? i18n(cfg.locale).propertyDefaults.title) + titleSuffix
    const description =
      fileData.frontmatter?.socialDescription ??
      fileData.frontmatter?.description ??
      unescapeHTML(fileData.description?.trim() ?? i18n(cfg.locale).propertyDefaults.description)

    const { css, js, additionalHead } = externalResources

    const url = new URL(`https://${cfg.baseUrl ?? "example.com"}`)
    const path = url.pathname as FullSlug
    const baseDir = fileData.slug === "404" ? path : pathToRoot(fileData.slug!)
    const iconPath = joinSegments(baseDir, "static/icon.png")

    // Url of current page
    const socialUrl =
      fileData.slug === "404" ? url.toString() : joinSegments(url.toString(), fileData.slug!)

    // Canonical URL
    const canonicalUrl = cfg.baseUrl
      ? `https://${cfg.baseUrl}/${fileData.slug === "index" ? "" : fileData.slug}`
      : undefined

    const usesCustomOgImage = ctx.cfg.plugins.emitters.some(
      (e) => e.name === CustomOgImagesEmitterName,
    )
    const ogImageDefaultPath = `https://${cfg.baseUrl}/static/og-image.png`

    // JSON-LD structured data
    const datePublished = getDate(cfg, fileData)
    const dateModified = fileData.dates?.modified
    const slug = fileData.slug ?? ""
    const isPost = slug !== "index" && slug !== "404"
    const jsonLd = isPost
      ? JSON.stringify({
          "@context": "https://schema.org",
          "@type": "BlogPosting",
          headline: fileData.frontmatter?.title ?? "",
          description: description,
          url: canonicalUrl,
          ...(datePublished && { datePublished: datePublished.toISOString() }),
          ...(dateModified && { dateModified: dateModified.toISOString() }),
          author: {
            "@type": "Person",
            name: "Jayden",
          },
          publisher: {
            "@type": "Organization",
            name: cfg.pageTitle,
          },
          mainEntityOfPage: {
            "@type": "WebPage",
            "@id": canonicalUrl,
          },
        })
      : undefined

    // BreadcrumbList structured data
    const slugParts = slug.split("/").filter(Boolean)
    const breadcrumbItems = [
      { name: "Home", url: `https://${cfg.baseUrl}/` },
      ...slugParts.map((part, i) => ({
        name: part,
        url:
          i < slugParts.length - 1
            ? `https://${cfg.baseUrl}/${slugParts.slice(0, i + 1).join("/")}/`
            : undefined,
      })),
    ]
    const breadcrumbJsonLd =
      isPost && slugParts.length > 0
        ? JSON.stringify({
            "@context": "https://schema.org",
            "@type": "BreadcrumbList",
            itemListElement: breadcrumbItems.map((item, i) => ({
              "@type": "ListItem",
              position: i + 1,
              name: item.name,
              ...(item.url && { item: item.url }),
            })),
          })
        : undefined

    return (
      <head>
        <title>{title}</title>
        <meta charSet="utf-8" />
        {cfg.theme.cdnCaching && cfg.theme.fontOrigin === "googleFonts" && (
          <>
            <link rel="preconnect" href="https://fonts.googleapis.com" />
            <link rel="preconnect" href="https://fonts.gstatic.com" />
            <link rel="stylesheet" href={googleFontHref(cfg.theme)} />
            {cfg.theme.typography.title && (
              <link rel="stylesheet" href={googleFontSubsetHref(cfg.theme, cfg.pageTitle)} />
            )}
          </>
        )}
        <link rel="preconnect" href="https://cdnjs.cloudflare.com" crossOrigin="anonymous" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        {/* Canonical URL */}
        {canonicalUrl && <link rel="canonical" href={canonicalUrl} />}

        <meta name="og:site_name" content={cfg.pageTitle}></meta>
        <meta property="og:title" content={title} />
        <meta property="og:type" content="website" />
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content={title} />
        <meta name="twitter:description" content={description} />
        <meta property="og:description" content={description} />
        <meta property="og:image:alt" content={description} />

        {!usesCustomOgImage && (
          <>
            <meta property="og:image" content={ogImageDefaultPath} />
            <meta property="og:image:url" content={ogImageDefaultPath} />
            <meta name="twitter:image" content={ogImageDefaultPath} />
            <meta
              property="og:image:type"
              content={`image/${getFileExtension(ogImageDefaultPath) ?? "png"}`}
            />
          </>
        )}

        {cfg.baseUrl && (
          <>
            <meta property="twitter:domain" content={cfg.baseUrl}></meta>
            <meta property="og:url" content={socialUrl}></meta>
            <meta property="twitter:url" content={socialUrl}></meta>
          </>
        )}

        <link rel="icon" href={iconPath} />
        <meta name="description" content={description} />
        <meta name="generator" content="Quartz" />

        {/* JSON-LD: BlogPosting */}
        {jsonLd && <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: jsonLd }} />}
        {/* JSON-LD: BreadcrumbList */}
        {breadcrumbJsonLd && (
          <script
            type="application/ld+json"
            dangerouslySetInnerHTML={{ __html: breadcrumbJsonLd }}
          />
        )}

        {css.map((resource) => CSSResourceToStyleElement(resource, true))}
        {js
          .filter((resource) => resource.loadTime === "beforeDOMReady")
          .map((res) => JSResourceToScriptElement(res, true))}
        {additionalHead.map((resource) => {
          if (typeof resource === "function") {
            return resource(fileData)
          } else {
            return resource
          }
        })}
      </head>
    )
  }

  return Head
}) satisfies QuartzComponentConstructor

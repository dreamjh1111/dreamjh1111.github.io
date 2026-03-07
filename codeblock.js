const COPY_TEXT_CHANGE_OFFSET = 1000;
const COPY_ERROR_MESSAGE = "코드를 복사할 수 없습니다. 다시 시도해 주세요.";
const COPY_ICON = `
  <svg width="14" height="14" fill="currentColor" class="icon" viewBox="0 0 16 16">
    <path fill-rule="evenodd" d="M4 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2zm2-1a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1zM2 5a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1v-1h1v1a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h1v1z"/>
  </svg>`;
const CHECK_ICON = `
  <svg width="14" height="14" viewBox="0 0 14 15" fill="none">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M11.746.07A.5.5 0 0011.5.003h-6a.5.5 0 00-.5.5v2.5H.5a.5.5 0 00-.5.5v10a.5.5 0 00.5.5h8a.5.5 0 00.5-.5v-2.5h4.5a.5.5 0 00.5-.5v-8a.498.498 0 00-.15-.357L11.857.154a.506.506 0 00-.11-.085zM9 10.003h4v-7h-1.5a.5.5 0 01-.5-.5v-1.5H6v2h.5a.5.5 0 01.357.15L8.85 5.147c.093.09.15.217.15.357v4.5zm-8-6v9h7v-7H6.5a.5.5 0 01-.5-.5v-1.5H1z" fill="currentColor"/>
  </svg>`;

const adjustLineWidths = (codeBody) => {
  const canvas = document.createElement("canvas");
  const context = canvas.getContext("2d");

  const computedStyle = window.getComputedStyle(codeBody);
  context.font = `${computedStyle.fontSize} ${computedStyle.fontFamily}`;

  const lines = codeBody.querySelectorAll(".line");
  let maxWidth = 0;

  lines.forEach((line) => {
    const textWidth = context.measureText(line.textContent).width;
    maxWidth = Math.max(maxWidth, textWidth);
  });

  maxWidth += 32;

  lines.forEach((line) => {
    line.style.width = `${maxWidth}px`;
  });
};

const copyBlockCode = async (target = null) => {
  if (!target) return;
  try {
    const code = decodeURI(target.dataset.code);

    await navigator.clipboard.writeText(code);
    target.innerHTML = CHECK_ICON;
    setTimeout(() => {
      target.innerHTML = COPY_ICON;
    }, COPY_TEXT_CHANGE_OFFSET);
  } catch (error) {
    alert(COPY_ERROR_MESSAGE);
    console.error(error);
  }
};

const func = () => {
  const codeBlocks = document.querySelectorAll("pre > code");

  for (const codeBlock of codeBlocks) {
    const codes = codeBlock.innerHTML.split(/\n/);

    const processedCodes = codes.reduce(
      (prevCodes, curCode) => prevCodes + `<div class="line">${curCode}</div>`,
      ""
    );

    const copyButton = `<button type="button" class="copy-btn" data-code="${encodeURI(
      codeBlock.textContent
    )}" onclick="copyBlockCode(this)">${COPY_ICON}</button>`;

    const codeBody = `<div class="code-body">${processedCodes}</div>`;

    const codeHeader = `
    <div class="code-header">
      <span class="red btn"></span>
      <span class="yellow btn"></span>
      <span class="green btn"></span>
      ${copyButton}
    </div>`;

    codeBlock.innerHTML = codeHeader + codeBody;

    const codeBodyElement = codeBlock.querySelector(".code-body");
    adjustLineWidths(codeBodyElement);
  }
};

window.addEventListener("load", () => {
  func();
});

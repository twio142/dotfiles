/** @type {import("markdownlint").Rule} */
export default {
  names: ["no-empty-line-in-list"],
  description:
    "Rule that reports an error for empty lines between adjacent list items.",
  tags: ["list"],
  parser: "micromark",
  function: (params, onError) => {
    const lists = params.parsers.micromark.tokens.filter(
      (token) => token.type === "listOrdered" || token.type === "listUnordered",
    );

    function dfs(list, lineMap) {
      for (const token of list.children) {
        if (token.type === "listItemPrefix") {
          lineMap[token.startLine] = true;
        } else if (
          token.type === "listOrdered" ||
          token.type === "listUnordered"
        ) {
          dfs(token, lineMap);
        }
      }
    }

    for (const list of lists) {
      const lineMap = new Array(params.lines.length).fill(false);
      dfs(list, lineMap);
      let afterList = false;
      let emptyLines = 0;

      for (let i = 0; i < params.lines.length; i++) {
        if (lineMap[i + 1]) {
          if (emptyLines > 0) {
            onError({
              lineNumber: i - emptyLines,
              detail: "Empty line(s) between adjacent list items.",
              context: params.lines[i - emptyLines + 1],
              fixInfo: {
                lineNumber: i - emptyLines + 1,
                deleteCount: -emptyLines,
              },
            });
          }
          afterList = true;
          emptyLines = 0;
        } else if (afterList) {
          if (params.lines[i].trim() === "") {
            emptyLines++;
          } else {
            afterList = false;
            emptyLines = 0;
          }
        }
      }
    }
  },
};

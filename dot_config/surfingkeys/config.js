/* global api, settings, chrome */
api.unmap('d');
api.unmap('u');
api.unmap('e');
api.unmap('E');
api.vunmap('E');
api.unmap('F');
api.unmap('ab');
api.unmap('af');
api.unmap('A');
api.vunmap('A');
api.unmap('B');
api.vunmap('B');
api.unmap('t');
api.vunmap('t');
api.unmap('D');
api.unmap('R');
api.unmap('S');
api.unmap('W');
api.vunmap('W');
api.vunmap('q');
api.unmap('r');
api.unmap('C');
api.unmap('cc');
api.unmap('cf');
api.unmap('cp');
api.unmap('cq');
api.unmap('x');
api.unmap('X');
api.unmap(';G');
api.unmap(';u');
api.unmap(';U');
api.unmap(';ap');
api.unmap(';cp');
api.unmap(';cq');
api.unmap(';db');
api.unmap(';dh');
api.unmap(';i');
api.unmap(';j');
api.unmap(';m');
api.unmap(';pa');
api.unmap(';pb');
api.unmap(';pc');
api.unmap(';pd');
api.unmap(';pf');
api.unmap(';ph');
api.unmap(';pj');
api.unmap(';pm');
api.unmap(';pp');
api.unmap(';ps');
api.unmap(';ql');
api.unmap(';t');
api.unmap(';w');
api.unmap(';yh');
api.unmap('<Ctrl-h>');
api.unmap('<Ctrl-j>');
api.unmap('<Ctrl-6>');

api.map('<F11>', '<Alt-s>');
api.mapkey('<F10>', '#3mute/unmute current tab', () => api.RUNTIME('muteTab'));

api.mapkey('l', '#4Next tab.', () => api.RUNTIME('nextTab'));
api.mapkey('h', '#4Previous tab', () => api.RUNTIME('previousTab'));
api.mapkey('>', '#2Scroll right', () => api.Normal.scroll('right'));
api.mapkey('<', '#2Scroll left', () => api.Normal.scroll('left'));
api.mapkey('<Ctrl-d>', '#2Page down', () => api.Normal.scroll('pageDown'));
api.mapkey('<Ctrl-u>', '#2Page up', () => api.Normal.scroll('pageUp'));
api.mapkey('q', '#4Close tab', () => api.RUNTIME('closeTab'));
api.mapkey('Q', '#4Restore closed tab', () => api.RUNTIME('openLast'));

api.mapkey('o', '#8Open a URL', () => {
  api.Front.openOmnibar({type: 'URLs'});
});

api.mapkey('\\', '#0enter ephemeral PassThrough mode to temporarily suppress SurfingKeys', () => {
  api.Normal.passThrough(500);
});

// Go to
api.map('gt', 'T');
api.mapkey('g,', '#12Open Chrome Settings', () => {
  api.tabOpenLink('chrome://settings/');
});
api.mapkey('[b', '#4Go back in history', () => history.go(-1), {repeatIgnore: true});
api.mapkey(']b', '#4Go forward in history', () => history.go(1), {repeatIgnore: true});
api.mapkey('{', '#4Go back in history', () => history.go(-1), {repeatIgnore: true});
api.mapkey('}', '#4Go forward in history', () => history.go(1), {repeatIgnore: true});
api.mapkey('<Ctrl-o>', '#4Go one tab history back', () => {
  api.RUNTIME('historyTab', {backward: true});
}, {repeatIgnore: true});
api.mapkey('<Ctrl-i>', '#4Go one tab history forward', () => {
  api.RUNTIME('historyTab', {backward: false});
}, {repeatIgnore: true});
api.mapkey('[u', '#4Go up one path in the URL', () => {
  let pathname = location.pathname;
  if (pathname.length > 1) {
    pathname = pathname.endsWith('/') ? pathname.substr(0, pathname.length - 1) : pathname;
    let last = pathname.lastIndexOf('/');
    let repeats = api.RUNTIME.repeats;
    api.RUNTIME.repeats = 1;
    while (repeats-- > 1) {
      const p = pathname.lastIndexOf('/', last - 1);
      if (p === -1) {
        break;
      } else {
        last = p;
      }
    }
    pathname = pathname.substr(0, last);
  }
  window.location.href = location.origin + pathname;
});
api.mapkey('[U', '#4Go to root of current URL hierarchy', () => {
  window.location.href = window.location.origin;
});
api.unmap('gu');
api.unmap('gU');
api.unmap('gT');
api.unmap('ga');
api.unmap('gc');
api.unmap('gf');
api.unmap('gk');
api.unmap('gn');
api.unmap('gr');
api.vunmap('gr');

// Tabs
api.mapkey('te', '#4Edit current URL with vim editor, and reload', () => {
  api.Front.showEditor(window.location.href, (data) => {
    window.location.href = data;
  }, 'url');
});
api.mapkey('tE', '#4Edit current URL with vim editor, and open in new tab', () => {
  api.Front.showEditor(window.location.href, (data) => {
    api.tabOpenLink(data);
  }, 'url');
});
api.mapkey('ti', '#8Open incognito window', () => {
  api.RUNTIME('openIncognito', { url: window.location.href });
});
api.mapkey('tn', '#3Open newtab', () => api.tabOpenLink('about:blank'));
api.mapkey('tr', '#8Open recently closed URL', () => {
  api.Front.openOmnibar({type: 'RecentlyClosed'})
});
api.mapkey('tR', '#3Restore closed tab', () => {
  chrome.sessions.restore();
});
api.mapkey('tw', '#3Move current tab to another window', () => {
  api.Front.openOmnibar(({type: 'Windows'}));
});
api.mapkey('ty', '#3Duplicate current tab', () => api.RUNTIME('duplicateTab'));
api.mapkey('tt', '#3List tabs', () => {
  api.Front.openOmnibar({type: 'Tabs'});
});

// Close
api.mapkey('gxH', '#3Close all tabs on left', () => {
  api.RUNTIME('closeTabsToLeft');
});
api.mapkey('gxL', '#3Close all tabs on right', () => {
  api.RUNTIME('closeTabsToRight');
});
api.unmap('gx0');
api.unmap('gx$');
api.unmap('gxt');
api.unmap('gxT');

// Click
api.mapkey('ci', '#1Click on an image', () => {
  api.Hints.create('img', (element, shiftKey) => {
    if (shiftKey) {
      const event = new MouseEvent('contextmenu', {
        bubbles: true,
        cancelable: true,
        view: window,
        button: 2,
        buttons: 2,
        clientX: 100,
        clientY: 100
      });
      element.dispatchEvent(event);
    } else {
      api.Hints.dispatchMouseClick(element);
    }
  });
});
api.map('ce', 'L');
api.mapkey('co', '#1Open a link in current tab', () => {
  api.Hints.create('', (element) => {
    window.location.href = element.href;
  });
});
api.mapkey('cm', '#1Open multiple links in a new tab', () => {
  api.Hints.create('', api.Hints.dispatchMouseClick, {multipleHits: true});
});
api.mapkey('ch', '#1Hover a link', () => {
  api.Hints.create('', (element) => {
    ['pointerover','mouseover','mouseenter'].forEach(type => {
      const Ctor = type.startsWith('pointer') ? PointerEvent : MouseEvent;
      element.dispatchEvent(new Ctor(type, {
        bubbles: true, cancelable: true, composed: true
      }));
    });
  });
});
api.map('cf', 'w');
api.map('cs', ';fs');

// Yank
api.mapkey('yt', '#7Copy current page\'s title', () => {
  api.Clipboard.write(document.title);
});
api.mapkey('ym', '#7Copy current page\'s markdown url', () => {
  api.Clipboard.write(`[${document.title}](${window.location.href})`)
});
api.mapkey('yi', '#7Yank text of an input', () => {
  api.Hints.create('input, textarea, select', (element) => {
    api.Clipboard.write(element.value);
  });
});
api.mapkey('yf', '#7Yank link url', () => {
  api.Hints.create('*[href]', (element, shiftKey) => {
    const link = shiftKey ? `[${element.textContent}](${element.href})` : element.href;
    api.Clipboard.write(link);
  });
});
api.mapkey('yg', '#7Yank git url', () => {
  const {pathname} = window.location;
  const url = `git@github.com:${pathname.slice(1)}.git`;
  api.Clipboard.write(url);
}, {domain: /github.com\/.+\/.+/i});
api.map('ys', 'yS');
api.unmap('yG');
api.unmap('yQ');
api.unmap('yd');
api.unmap('ya');
api.unmap('yc');
api.unmap('yl');
api.unmap('yj');
api.unmap('yp');
api.unmap('yq');
api.unmap('yY');
api.unmap('yT');

// Visual mode
api.vmap('H', '0');
api.vmap('L', '$');
api.vmap('+', 'p');
function click(el, opts) {
  const event = new MouseEvent('click', {
    bubbles: true,
    cancelable: true,
    composed: true,
    view: window,
    altKey: false,
    ctrlKey: false,
    shiftKey: false,
    metaKey: false,
    ...opts,
  });
  el?.dispatchEvent(event);
}
api.vmapkey('<Meta-Enter>', '#9Click on node under cursor.', () => {
  click(document.getSelection().focusNode.parentNode, { metaKey: true });
});
api.vmapkey('<Alt-Enter>', '#9Click on node under cursor.', () => {
  click(document.getSelection().focusNode.parentNode, { altKey: true });
});
api.vmapkey('<Shift-Enter>', '#9Click on node under cursor.', () => {
  click(document.getSelection().focusNode.parentNode, { shiftKey: true });
});

// Omnibar
api.cmap('<Ctrl-j>', '<Tab>');
api.cmap('<Ctrl-k>', '<Shift-Tab>');
api.cmap('<Ctrl-y>', '<Ctrl-c>');
api.cmap('<Ctrl-d>', '<Ctrl-.>');
api.cmap('<Ctrl-u>', '<Ctrl-,>');

// Insert mode
api.imap('jh', '<Esc>');

// Vim editor bindings
api.aceVimMap('H', '^', 'normal');
api.aceVimMap('L', '$', 'normal');
api.aceVimMap('jk', '<Esc>', 'insert');

// Search aliases
api.addSearchAlias('i', 'google images', 'https://www.google.com/search?tbm=isch&q=', 's', 'https://www.google.com/complete/search?client=chrome-omni&gs_ri=chrome-ext&oit=1&cp=1&pgcl=7&q=', (response) => {
  const res = JSON.parse(response.text);
  return res[1];
});
api.addSearchAlias('p', 'perplexity', 'https://www.perplexity.ai/?q=', 's');
api.addSearchAlias('w', 'wikipedia', 'https://en.wikipedia.org/wiki/', 's', 'https://en.wikipedia.org/w/api.php?action=opensearch&format=json&formatversion=2&namespace=0&limit=40&search=', (response) => {
  return JSON.parse(response.text)[1];
});
api.addSearchAlias('wk', 'wikipedia', 'https://en.wikipedia.org/wiki/', 's', 'https://en.wikipedia.org/w/api.php?action=opensearch&format=json&formatversion=2&namespace=0&limit=40&search=', (response) => {
  return JSON.parse(response.text)[1];
});
api.addSearchAlias('wk/zh', 'wikipedia (zh)', 'https://zh.wikipedia.org/wiki/', 's', 'https://zh.wikipedia.org/w/api.php?action=opensearch&format=json&formatversion=2&namespace=0&limit=40&search=', (response) => {
  return JSON.parse(response.text)[1];
});
api.addSearchAlias('gh', 'github', 'https://github.com/search?q=', 's', 'https://api.github.com/search/repositories?order=desc&q=', (response) => {
  const res = JSON.parse(response.text).items;
  return res ? res.map((r) => {
    return {
      title: r.description,
      url: r.html_url
    };
  }) : [];
});
api.addSearchAlias('yt', 'youtube', 'https://www.youtube.com/results?search_query=', 's',
'https://clients1.google.com/complete/search?client=youtube&ds=yt&callback=cb&q=', (response) => {
  const res = JSON.parse(response.text.substr(9, response.text.length-10));
  return res[1].map((d) => {
    return d[0];
  });
});
api.addSearchAlias('b', 'bilibili', 'https://www.bilibili.com/search?keyword=', 's',
'https://s.search.bilibili.com/main/suggest?func=suggest&suggest_type=accurate&sub_type=tag&main_ver=v1&term=', (response) => {
  const res = JSON.parse(response.text).result.tag;
  return res.map((d) => d.term);
});
api.addSearchAlias('a', 'amazon', 'https://www.amazon.de/s/?field-keywords=', 's',
'https://completion.amazon.de/api/2017/suggestions?limit=11&alias=aps&lop=de_DE&mid=A1PA6795UKMFR9&prefix=', (response) => {
  const res = JSON.parse(response.text).suggestions;
  return res.map((d) => d.value);
});
api.removeSearchAlias('e');
api.removeSearchAlias('s');

// Settings
settings.enableEmojiInsertion = true;
settings.startToShowEmoji = 2;
settings.defaultSearchEngine = 'p';
settings.focusFirstCandidate = false;
settings.modeAfterYank = 'Normal';
// settings.blocklistPattern = /.../i;

// Theme
settings.theme = `
:root {
  /* Font */
  --font: 'Source Code Pro', 'Source Code Pro for Powerline', Ubuntu, monospace;
  --font-size: 12;
  --font-weight: normal;

  /* Colors */
  --fg: #1D1F21;
  --bg: #ececea;
  --bg-dark: #E0E0E0;
  --border: #c7c9c4;
  --main-fg: #5b7d00;
  --accent-fg: #0e1b02;
  --info-fg: #a650bf;
  --select: #A0A0A0;

  --cyan: #4CB3BC;
  --orange: #DE935F;
  --red: #CC6666;
  --yellow: #CBCA77;

  --hint-fg: #990000;
}
@media (prefers-color-scheme: dark) {
  :root {
    --fg: #C5C8C6;
    --bg: #282A2E;
    --bg-dark: #1D1F21;
    --border: #373b41;
    --main-fg: #5E81AC;
    --accent-fg: #F8F8F2;
    --info-fg: #AC7BBA;
    --select: #585858;

    --hint-fg: #A6E22E;
  }
}

/* ---------- Generic ---------- */
.sk_theme {
background: var(--bg);
color: var(--fg);
  background-color: var(--bg);
  border-color: var(--border);
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}

input {
  font-family: var(--font);
  font-weight: var(--font-weight);
}

.sk_theme tbody {
  color: var(--fg);
}

.sk_theme input {
  color: var(--fg);
}

/* Hints */
#sk_hints .begin {
  color: var(--accent-fg) !important;
}

#sk_tabs .sk_tab {
  background: var(--bg-dark);
  border: 1px solid var(--border);
}

#sk_tabs .sk_tab_title {
  color: var(--fg);
}

#sk_tabs .sk_tab_url {
  color: var(--main-fg);
}

#sk_omnibarSearchResult li div.url {
  font-weight: normal !important;
}

#sk_tabs .sk_tab_hint {
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--hint-fg);
}

.sk_theme #sk_frame {
  background: var(--bg);
  opacity: 0.2;
  color: var(--accent-fg);
}

/* ---------- Omnibar ---------- */
/* Uncomment this and use settings.omnibarPosition = 'bottom' for Pentadactyl/Tridactyl style bottom bar */
/* .sk_theme#sk_omnibar {
  width: 100%;
  left: 0;
} */

.sk_theme .title {
  color: var(--accent-fg);
}

.sk_theme .url {
  color: var(--main-fg);
}

.sk_theme .annotation {
  color: var(--accent-fg);
}

.sk_theme .omnibar_highlight {
  color: var(--accent-fg);
}

.sk_theme .omnibar_timestamp {
  color: var(--info-fg);
}

.sk_theme .omnibar_visitcount {
  color: var(--accent-fg);
}

.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: var(--bg);
}

.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: var(--border);
}

.sk_theme #sk_omnibarSearchArea {
  border-top-color: var(--border);
  border-bottom-color: var(--border);
}

.sk_theme #sk_omnibarSearchArea input,
.sk_theme #sk_omnibarSearchArea span {
  font-size: var(--font-size);
}

.sk_theme .separator {
  color: var(--accent-fg);
}

/* ---------- Popup Notification Banner ---------- */
#sk_banner {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
  background: var(--bg);
  border-color: var(--border);
  color: var(--fg);
  opacity: 0.9;
}

/* ---------- Popup Keys ---------- */
#sk_keystroke {
  background-color: var(--bg);
  color: var(--fg);
  border-top-left-radius: 6px;
}

.sk_theme kbd .candidates {
  color: var(--info-fg);
}

.sk_theme span.annotation {
  color: var(--accent-fg);
}

/* ---------- Popup Translation Bubble ---------- */
#sk_bubble {
  background-color: var(--bg) !important;
  color: var(--fg) !important;
  border-color: var(--border) !important;
}

#sk_bubble * {
  color: var(--fg) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(1) {
  border-top-color: var(--border) !important;
  border-bottom-color: var(--border) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(2) {
  border-top-color: var(--bg) !important;
  border-bottom-color: var(--bg) !important;
}

/* ---------- Search ---------- */
#sk_status,
#sk_find {
  font-size: var(--font-size);
  border-color: var(--border);
}

.sk_theme kbd {
  background: var(--bg-dark);
  border-color: var(--border);
  box-shadow: none;
  color: var(--fg);
}

.sk_theme .feature_name span {
  color: var(--main-fg);
}

/* ---------- ACE Editor ---------- */
#sk_editor {
  background: var(--bg-dark) !important;
  height: 50% !important;
  /* Remove this to restore the default editor size */
}

.ace_dialog-bottom {
  border-top: 1px solid var(--bg) !important;
}

.ace-chrome .ace_print-margin,
.ace_gutter,
.ace_gutter-cell,
.ace_dialog {
  background: var(--bg) !important;
}

.ace-chrome {
  color: var(--fg) !important;
}

.ace_gutter,
.ace_dialog {
  color: var(--fg) !important;
}

.ace_cursor {
  color: var(--fg) !important;
}

.normal-mode .ace_cursor {
  background-color: var(--fg) !important;
  border: var(--fg) !important;
  opacity: 0.7 !important;
}

.ace_marker-layer .ace_selection {
  background: var(--select) !important;
}

.ace_editor,
.ace_dialog span,
.ace_dialog input {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}
`;

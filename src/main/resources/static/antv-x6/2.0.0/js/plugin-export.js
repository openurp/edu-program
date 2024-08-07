!function(t,e){"object"==typeof exports&&"undefined"!=typeof module?e(exports,require("@antv/x6")):"function"==typeof define&&define.amd?define(["exports","@antv/x6"],e):e((t="undefined"!=typeof globalThis?globalThis:t||self).X6PluginExport={},t.X6)}(this,(function(t,e){"use strict";e.Graph.prototype.toSVG=function(t,e){const o=this.getPlugin("export");o&&o.toSVG(t,e)},e.Graph.prototype.toPNG=function(t,e){const o=this.getPlugin("export");o&&o.toPNG(t,e)},e.Graph.prototype.toJPEG=function(t,e){const o=this.getPlugin("export");o&&o.toJPEG(t,e)},e.Graph.prototype.exportPNG=function(t,e){const o=this.getPlugin("export");o&&o.exportPNG(t,e)},e.Graph.prototype.exportJPEG=function(t,e){const o=this.getPlugin("export");o&&o.exportJPEG(t,e)},e.Graph.prototype.exportSVG=function(t,e){const o=this.getPlugin("export");o&&o.exportSVG(t,e)};class o extends e.Basecoat{constructor(){super(),this.name="export"}get view(){return this.graph.view}init(t){this.graph=t}exportPNG(t="chart",o={}){this.toPNG((o=>{e.DataUri.downloadDataUri(o,t)}),o)}exportJPEG(t="chart",o={}){this.toPNG((o=>{e.DataUri.downloadDataUri(o,t)}),o)}exportSVG(t="chart",o={}){this.toSVG((o=>{e.DataUri.downloadDataUri(e.DataUri.svgToDataUrl(o),t)}),o)}toSVG(t,o={}){this.notify("before:export",o);const i=this.view.svg,r=e.Vector.create(i).clone();let n=r.node;const s=r.findOne(`.${this.view.prefixClassName("graph-svg-stage")}`),a=o.viewBox||this.graph.graphToLocal(this.graph.getContentBBox()),h=o.preserveDimensions;if(h){const t="boolean"==typeof h?a:h;r.attr({width:t.width,height:t.height})}if(r.removeAttribute("style").attr("viewBox",[a.x,a.y,a.width,a.height].join(" ")),s.removeAttribute("transform"),!1!==o.copyStyles){const t=i.ownerDocument,o=Array.from(i.querySelectorAll("*")),r=Array.from(n.querySelectorAll("*")),s=t.styleSheets.length,a=[];for(let e=s-1;e>=0;e-=1)a[e]=t.styleSheets[e],t.styleSheets[e].disabled=!0;const h={};o.forEach(((t,e)=>{const o=window.getComputedStyle(t,null),i={};Object.keys(o).forEach((t=>{i[t]=o.getPropertyValue(t)})),h[e]=i})),s!==t.styleSheets.length&&a.forEach(((e,o)=>{t.styleSheets[o]=e}));for(let e=0;e<s;e+=1)t.styleSheets[e].disabled=!1;const c={};o.forEach(((t,o)=>{const i=window.getComputedStyle(t,null),r=h[o],n={};Object.keys(i).forEach((t=>{e.NumberExt.isNumber(t)||i.getPropertyValue(t)===r[t]||(n[t]=i.getPropertyValue(t))})),c[o]=n})),r.forEach(((t,o)=>{e.Dom.css(t,c[o])}))}const c=o.stylesheet;if("string"==typeof c){const t=i.ownerDocument.implementation.createDocument(null,"xml",null).createCDATASection(c);r.prepend(e.Vector.create("style",{type:"text/css"},[t]))}const l=()=>{const i=o.beforeSerialize;if("function"==typeof i){const t=e.FunctionExt.call(i,this.graph,n);t instanceof SVGSVGElement&&(n=t)}const r=(new XMLSerializer).serializeToString(n).replace(/&nbsp;/g," ");this.notify("after:export",o),t(r)};if(o.serializeImages){const t=r.find("image").map((t=>new Promise((o=>{const i=t.attr("xlink:href")||t.attr("href");e.DataUri.imageToDataUri(i,((e,i)=>{!e&&i&&t.attr("xlink:href",i),o()}))}))));Promise.all(t).then(l)}else l()}toDataURL(t,o){let i=o.viewBox||this.graph.getContentBBox();const r=e.NumberExt.normalizeSides(o.padding);o.width&&o.height&&(r.left+r.right>=o.width&&(r.left=r.right=0),r.top+r.bottom>=o.height&&(r.top=r.bottom=0));const n=new e.Rectangle(-r.left,-r.top,r.left+r.right,r.top+r.bottom);if(o.width&&o.height){const t=i.width+r.left+r.right,e=i.height+r.top+r.bottom;n.scale(t/o.width,e/o.height)}i=e.Rectangle.create(i).moveAndExpand(n);const s="number"==typeof o.width&&"number"==typeof o.height?{width:o.width,height:o.height}:i;let a=o.ratio?parseFloat(o.ratio):1;Number.isFinite(a)&&0!==a||(a=1);const h={width:Math.max(Math.round(s.width*a),1),height:Math.max(Math.round(s.height*a),1)};{const t=document.createElement("canvas"),e=t.getContext("2d");t.width=h.width,t.height=h.height;const o=h.width-1,i=h.height-1;e.fillStyle="rgb(1,1,1)",e.fillRect(o,i,1,1);const r=e.getImageData(o,i,1,1).data;if(1!==r[0]||1!==r[1]||1!==r[2])throw new Error("size exceeded")}const c=new Image;c.onload=()=>{const e=document.createElement("canvas");e.width=h.width,e.height=h.height;const i=e.getContext("2d");i.fillStyle=o.backgroundColor||"white",i.fillRect(0,0,h.width,h.height);try{i.drawImage(c,0,0,h.width,h.height);const r=e.toDataURL(o.type,o.quality);t(r)}catch(t){}},this.toSVG((t=>{c.src=`data:image/svg+xml,${encodeURIComponent(t)}`}),Object.assign(Object.assign({},o),{viewBox:i,serializeImages:!0,preserveDimensions:Object.assign({},h)}))}toPNG(t,e={}){this.toDataURL(t,Object.assign(Object.assign({},e),{type:"image/png"}))}toJPEG(t,e={}){this.toDataURL(t,Object.assign(Object.assign({},e),{type:"image/jpeg"}))}notify(t,e){this.trigger(t,e),this.graph.trigger(t,e)}dispose(){this.off()}}!function(t,e,o,i){var r,n=arguments.length,s=n<3?e:null===i?i=Object.getOwnPropertyDescriptor(e,o):i;if("object"==typeof Reflect&&"function"==typeof Reflect.decorate)s=Reflect.decorate(t,e,o,i);else for(var a=t.length-1;a>=0;a--)(r=t[a])&&(s=(n<3?r(s):n>3?r(e,o,s):r(e,o))||s);n>3&&s&&Object.defineProperty(e,o,s)}([e.Basecoat.dispose()],o.prototype,"dispose",null),t.Export=o}));

//# sourceMappingURL=index.js.map

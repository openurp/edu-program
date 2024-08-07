  [#macro displaySection name level]
    <h${level+2} [#if level>1]style="margin-top:.5rem;"[/#if]>${name}</h${level+2}>
  [/#macro]

  [#macro p contents=""]
  <p style="white-space: preserve;text-indent:2em;">${contents}[#nested/]</p>
  [/#macro]

  [#macro p2 contents=""]
  <p style="white-space: preserve;text-indent:2em;" class="mb-0">${contents}[#nested/]</p>
  [/#macro]

  [#macro multi_line_p]
    [#assign cnts][#nested/][/#assign]
    [#assign ps = cnts?split("\n")]
    [#list ps as p]
    <p style="white-space: preserve;text-indent:2em;" class="mb-0">${p}</p>
    [/#list]
  [/#macro]
  [#if program.level.name=='专科']
  [#include "doc_zhuanke.ftl"/]
  [#else]
  [#include "doc_benke.ftl"/]
  [/#if]

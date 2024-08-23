[@b.head loadui=false smallText=false/]
  <div class="container">
  [#include "/org/openurp/edu/program/web/components/report/style.ftl"/]
  [#if doc??]
    [#include "/org/openurp/edu/program/web/components/report/header.ftl"/]
    [#include "/org/openurp/edu/program/web/components/report/doc.ftl"/]
  [/#if]
  [#include "/org/openurp/edu/program/web/components/report/plan.ftl"/]
  </div>
[@b.foot/]

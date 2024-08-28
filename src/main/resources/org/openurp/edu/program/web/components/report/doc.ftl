    [#list doc.sections as section]
        <p style="font-weight:bold;font-size:1.2rem;text-align:left;">${topSeq.next}、${(section.name?html)!}</p>
        <p style="text-align:left;text-indent: 2rem;">
            ${section.contents!('')?replace("\n","<br/>")}
        </p>
    [/#list]

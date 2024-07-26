[
  [#assign termNames=["第一学期","第二学期","第三学期","第四学期","第五学期","第六学期","第七学期","第八学期"] /]
  [#list termNames as termName]
  {
    "id": "term${termName_index+1}",
    "shape": "lane",
    "width": 200,
    "height": 500,
    "position": {
      "x": ${termName_index*200},
      "y": 0
    },
    "label": "${termName}"
  },[/#list]
  [#list termGroups as group]
    [#if group?size > 0]
    [#list group as pc]
    {
      "id": "course${pc.course.id}",
      "shape": "lane-rect",
      [#assign courseName=pc.course.name/]
      [#assign width=100/][#if Chars.charLength(pc.course.name)*6.5 >100]
        [#assign width=Chars.charLength(pc.course.name)*6.5/]
        [#if width > 180]
          [#assign width=180/]
          [#assign courseName=courseName[0..10]+"\n"+courseName[10..]/]
        [/#if]
      [/#if]
      "width": ${width},
      "height": 30,
      "position": {
        "x": ${(100-width/2)+group_index*200},
        "y": ${60+pc_index*60}
      },
      "label": "${courseName?js_string}",
      "parent": "term${group_index+1}"
    },
    [/#list]
    [/#if]
  [/#list]
  [#list prerequisites as pre]
   {
      "id": "edge${pre.id}",
      "shape": "lane-edge",
      "source": "course${pre.prerequisite.id}",
      "target": "course${pre.course.id}"
    }[#sep],
  [/#list]
]

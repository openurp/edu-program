[@b.head loadui=false/]
    <script src="${b.base}/static/antv-x6/2.0.0/js/index.js"></script>
    <script src="${b.base}/static/antv-x6/2.0.0/js/plugin-export.js"></script>
    <div class="card card-info card-primary card-outline">
      [@b.card_header style="text-align: center;"]
        ${program.grade.code}级 ${program.major.name}[#if program.direction??]（${program.direction.name}）[/#if] 课程学期关系图
        <a href="${b.url('!graph')}?program.id=${program.id}&ignoreTermGap=[#if (Parameters['ignoreTermGap']!"1")=="1"]0[#else]1[/#if]"
         style="color: #17a2b8;border: 1px solid #17a2b8;padding: .25rem .5rem;border-radius: .2rem;text-decoration: none;font-weight: 400;">
           <i class="fa-solid fa-floppy-disk"></i>[#if (Parameters['ignoreTermGap']!"1")=="1"]显示跨学期先修关系[#else]忽略跨学期先修关系[/#if]
        </a>
        <a href="#" onclick="return saveLayout();"
         style="color: #17a2b8;border: 1px solid #17a2b8;padding: .25rem .5rem;border-radius: .2rem;text-decoration: none;font-weight: 400;">
           <i class="fa-solid fa-floppy-disk"></i>保存布局
        </a>
      [/@]
    </div>
    [#assign maxTermCourseCount=0 /]
    [#list termGroups as group][#if group?size  > maxTermCourseCount] [#assign maxTermCourseCount = group?size/] [/#if][/#list]
    [#if maxTermCourseCount==0][#assign maxTermCourseCount=1/][/#if]
    <div id="container" style="height: ${maxTermCourseCount*60+100}px;width:98vw"></div>
    <script type="module">
      const { Graph,DataUri } = X6;
      const { Export } = X6PluginExport;
      var data=[
        [#if program.terms = 8 ]
        [#assign termNames=["第一学期","第二学期","第三学期","第四学期","第五学期","第六学期","第七学期","第八学期"] /]
        [#elseif program.terms = 6]
        [#assign termNames=["第一学期","第二学期","第三学期","第四学期","第五学期","第六学期"] /]
        [#elseif program.terms = 4]
        [#assign termNames=["第一学期","第二学期","第三学期","第四学期"] /]
        [/#if]
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

      Graph.registerNode(
        "lane",
        {
          inherit: "rect",
          markup: [
            {
              tagName: "rect",
              selector: "body",
            },
            {
              tagName: "rect",
              selector: "name-rect",
            },
            {
              tagName: "text",
              selector: "name-text",
            },
          ],
          attrs: {
            body: {
              fill: "#FFF",
              stroke: "#5F95FF",
              strokeWidth: 0,
            },
            "name-rect": {
              width: 200,
              height: 30,
              fill: "#5F95FF",
              stroke: "#fff",
              strokeWidth: 1,
              x: -1,
            },
            "name-text": {
              ref: "name-rect",
              refY: 0.5,
              refX: 0.5,
              textAnchor: "middle",
              fontWeight: "bold",
              fill: "#fff",
              fontSize: 12,
            },
          },
        },
        true
      );

      Graph.registerNode(
        "lane-rect",
        {
          inherit: "rect",
          width: 100,
          height: 30,
          attrs: {
            body: {
              strokeWidth: 1,
              stroke: "#5F95FF",
              fill: "#EFF4FF",
            },
            text: {
              fontSize: 12,
              fill: "#262626",
            },
          },
        },
        true
      );

      Graph.registerNode(
        "lane-polygon",
        {
          inherit: "polygon",
          width: 80,
          height: 80,
          attrs: {
            body: {
              strokeWidth: 1,
              stroke: "#5F95FF",
              fill: "#EFF4FF",
              refPoints: "0,10 10,0 20,10 10,20",
            },
            text: {
              fontSize: 12,
              fill: "#262626",
            },
          },
        },
        true
      );

      Graph.registerEdge(
        "lane-edge",
        {
          inherit: "edge",
          attrs: {
            line: {
              stroke: "#A2B1C3",
              strokeWidth: 1,
            },
          },
          label: {
            attrs: {
              label: {
                fill: "#A2B1C3",
                fontSize: 12,
              },
            },
          },
        },
        true
      );

      const graph = new Graph({
        container: document.querySelector("#container"),
        /*background:{
          color:'#F2F7FA',
        },*/
        connecting: {
          router: {
            name:"metro",
            args:{
              startDirections:['right'],
              endDirections:['left','right'],
            }
          },
          connector: {
            name: "rounded",
            args:{
              radius:10,
            }
          },
        },
        translating: {
          restrict(cellView) {
            const cell = cellView.cell;
            const parentId = cell.prop("parent");
            if (parentId) {
              const parentNode = graph.getCellById(parentId);
              if (parentNode) {
                return parentNode.getBBox().moveAndExpand({
                  x: 0,
                  y: 30,
                  width: 0,
                  height: -30,
                });
              }
            }
            return cell.getBBox();
          },
        },
      });

      const cells = [];
      data.forEach((item) => {
        if (item.shape === "lane-edge") {
          cells.push(graph.createEdge(item));
        } else {
          cells.push(graph.createNode(item));
        }
      });
      graph.resetCells(cells);
      graph.zoomToFit({ padding: 10, maxScale: 1 });
      graph.use(new Export());

    [#if upload!false]
    setTimeout(saveLayout,1000);
    [/#if]
    function saveLayout(){
      graph.toPNG(dataUri=>{document.uploadForm['pngData'].value=dataUri; bg.form.submit(document.uploadForm);},{quality:1,backgroundColor:'#fff',width:2800,height:1000});
      return false;
    }
    window.saveLayout = saveLayout ;
    </script>
    [@b.div]
      [@b.form action="!upload" name="uploadForm"]
        <input type="hidden" value="${program.id}" name="program.id"/>
        <input type="hidden" value="" name="pngData"/>
      [/@]
    [/@]
[@b.foot/]

[@b.head loadui=false/]
    <script src="${b.base}/static/antv-x6/2.0.0/js/index.js"></script>
    <div id="container" style="height: 400px;width:100vw"></div>
    <script>
      const { Graph } = X6;
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
        background:{
          color:'#F2F7FA',
        },
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

      fetch("${b.url('!dependencyData')}?program.id=${program.id}")
        .then((response) => response.json())
        .then((data) => {
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
        });
    </script>
[@b.foot/]

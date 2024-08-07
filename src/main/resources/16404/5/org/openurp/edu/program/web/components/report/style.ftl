<style>
  @page {
    size: A4;
    margin: 15mm;
  }
  body{
    font-family:'Times New Roman',宋体;
    font-size:12pt;
    line-height:1.5rem;
    margin:auto;
  }
  @media (min-width: 1200px) {
    .container{
      max-width: 1140px;
    }
  }
  .container{
    width: 100%;
    margin-right: auto;
    margin-left: auto;
  }
  h2{
    font-size:16pt;
  }
  h3{
    font-weight:bold;
    font-size:14pt;
  }
  h4{
    font-weight:bold;
    font-size:12pt;
  }
  h2,h3,h4{
    line-height:1.2rem;
    margin-top:0.5rem;
    margin-bottom: .5rem;
  }
  p{
    margin-top:0px;
  }
  .mb-0{
    margin-bottom:0px;
  }
  .doc-table{
    font-size:10.5pt;
    width: 100%;
    text-align:center;
    table-layout: fixed;
    border-collapse: collapse;
  }
  .doc-table tr {
    word-wrap: break-word;
  }
  .doc-table td, .doc-table th {
    border: 0.5px solid black;
    overflow: hidden;
  }
  .plan-table{
    font-size:10pt;
    line-height:1.1rem;
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    text-align:center;
  }
  .plan-table tr {
    word-wrap: break-word;
  }
  .plan-table td, .plan-table th {
    border: 0.5px solid black;
    overflow: hidden;
  }
  .course{
    text-align:left;
    padding-left: 5px;
  }
  .level2module{
    font-weight:bold;
  }
  td.footer{
    border: 0px;
    text-align:left;
  }
  @media print{
    body{
      width:180mm;
    }
    .plan-table{
      font-size:7.4pt;
      line-height:8pt;
    }
  }
  .table-repeat-header{
     visibility:collapse;
  }
  .prerequisite-screen{
    display:block;
  }
  .prerequisite-print{
    display:none;
  }
  .prerequisite-caption{
    inline-size: fit-content;
    position: absolute;
    display: inline-block;
    bottom: 0px;
    text-align: right;
    transform: rotate(-90deg) translateY(100%);
    transform-origin: left bottom;
  }
  @media print {
    .table-repeat-header{
       visibility:initial;
    }
    .prerequisite-screen{
      display:none;
    }
    .prerequisite-print{
      display:block;
    }
  }
</style>

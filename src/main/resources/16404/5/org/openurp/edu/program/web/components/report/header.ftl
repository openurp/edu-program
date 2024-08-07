<div style="text-align:center;margin:1rem 0rem;">
  <h2>${program.department.name}</h2>
  <h2 style="font-family:楷体;">${program.grade.code}级${program.major.name}[#if program.direction??]（${program.direction.name?replace("方向","")}）[/#if]专业${program.level.name}培养方案</h2>
  <table width="100%">
    <tr>
      <td width="50%">专业代码：${program.disciplineCode!}</td>
      <td width="50%">授予学位：${(program.degree.name)!'--'}</td>
    </tr>
  </table>
</div>

[#ftl]
[#macro drawTreeLineSimple courseGroup]
    [#local lv = courseGroup.depth/]
    [#if lv == 1][/#if]
    [#if lv &gt; 1][#list 1..(lv-1) as i][#if i == 1]&nbsp;&nbsp;[#else]&nbsp;&nbsp;&nbsp;&nbsp;[/#if]|[/#list]--[/#if]
[/#macro]

[#-- 课程设置按钮 --]
[#macro courseButton courseGroup]
    <div style='display:inline-block;'>
        <button onclick="arrangeGroupCourses(${courseGroup.id})" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" style="width:25px;height:25px;" title="课程设置">
            <span class="ui-button-icon-primary ui-icon ui-icon-gear"></span>
            <span class="ui-button-text">课程设置</span>
        </button>
    </div>
[/#macro]

[#-- 修改按钮 --]
[#macro editButton courseGroup]
<button onclick="edit(${courseGroup.id})" title="修改" class="btn btn-sm btn-outline-primary" style="font-size:9px !important;line-height:9px;height:25px"><i aria-hidden="true" class="fas fa-cog"></i></button>
[/#macro]

[#-- 删除按钮 --]
[#macro removeButton courseGroup]
<button onclick="removeGroup(${courseGroup.id})" class="btn btn-sm btn-outline-danger" title="删除" style="font-size:9px !important;line-height:9px;height:25px"><i aria-hidden="true" class="fas fa-times"></i></button>
[/#macro]

[#-- 判断一个课程组是否还可以上移/下移 --]
[#macro moveUpButton courseGroup]
    [#local canMoveUp = false /]
    [#if !courseGroup.parent??]
        [#if courseGroup.plan.topCourseGroups?seq_index_of(courseGroup) != 0]
            [#local canMoveUp = true /]
        [/#if]
    [#else]
        [#if courseGroup != courseGroup.parent.children?first]
            [#local canMoveUp = true /]
        [/#if]
    [/#if]
    [#if canMoveUp]
        <div style='display:inline-block;'>
            <button onclick="groupMoveUp(${courseGroup.id})" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" style="width:25px;height:25px;" title="向上">
                <span class="ui-button-icon-primary ui-icon ui-icon-arrowthick-1-n"></span>
                <span class="ui-button-text">向上</span>
            </button>
        </div>
    [/#if]
[/#macro]

[#macro moveDownButton courseGroup]
    [#local canMoveDown = false /]
    [#if !courseGroup.parent??]
        [#if courseGroup.plan.topCourseGroups?seq_index_of(courseGroup) != courseGroup.plan.topCourseGroups?size - 1]
            [#local canMoveDown = true /]
        [/#if]
    [#else]
        [#if courseGroup.parent.children?last != courseGroup]
            [#local canMoveDown = true /]
        [/#if]
    [/#if]
    [#if canMoveDown]
        <div style='display:inline-block;'>
            <button onclick="groupMoveDown(${courseGroup.id})" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" style="width:25px;height:25px;" title="向下">
                <span class="ui-button-icon-primary ui-icon ui-icon-arrowthick-1-s"></span>
                <span class="ui-button-text">向下</span>
            </button>
        </div>
    [/#if]
[/#macro]

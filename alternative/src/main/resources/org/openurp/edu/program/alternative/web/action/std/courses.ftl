[#ftl]
{courses : [[#list courses! as course]{id : '${(course.id)!}', name : '${(course.name)!}', code : '${(course.code)!}'}[#if course_has_next],[/#if][/#list]]}

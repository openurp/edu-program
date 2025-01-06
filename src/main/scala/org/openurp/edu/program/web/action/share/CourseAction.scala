/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.edu.program.web.action.share

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Course, Terms}
import org.openurp.base.model.{CalendarStage, Project}
import org.openurp.code.edu.model.*
import org.openurp.code.person.model.Language
import org.openurp.edu.program.model.*
import org.openurp.edu.program.service.{SharePlanService, TermHelper}
import org.openurp.starter.web.support.ProjectSupport

class CourseAction extends ActionSupport, EntityAction[SharePlan], ProjectSupport {

  var entityDao: EntityDao = _
  var planService: SharePlanService = _

  override protected def simpleEntityName: String = "plan"

  def groups(): View = {
    val plan = entityDao.get(classOf[SharePlan], getLongId("plan"))
    getLong("courseGroup.id") foreach { groupId =>
      put("activeGroup", entityDao.get(classOf[ShareCourseGroup], groupId))
    }
    put("plan", plan)
    forward()
  }

  def editGroup(): View = {
    val planId = getLongId("plan")
    val plan = entityDao.get(classOf[SharePlan], planId)

    given project: Project = plan.project

    val unusedCourseTypeList = getCodes(classOf[CourseType])
    val group = getLong("courseGroup.id") match
      case None =>
        val ng = new ShareCourseGroup
        ng.indexno = "99"
        ng
      case Some(gid) =>
        entityDao.get(classOf[ShareCourseGroup], gid)
    put("courseGroup", group)

    put("unusedCourseTypeList", unusedCourseTypeList)
    put("parentCourseGroupList", plan.groups)
    put("languages", getCodes(classOf[Language]))
    put("abilityRates", entityDao.getAll(classOf[CourseAbilityRate]))
    put("plan", plan)
    forward()
  }

  def saveGroup(): View = {
    val plan = entityDao.get(classOf[SharePlan], getLongId("plan"))

    given project: Project = plan.project

    val group = populateEntity(classOf[ShareCourseGroup], "courseGroup")
    val oldParent = group.parent.orNull
    val parentId = getLong("newParentId")
    var parent: ShareCourseGroup = null
    var index = getInt("index", 0)
    if (parentId.nonEmpty) {
      parent = entityDao.get(classOf[ShareCourseGroup], parentId.get)
      if (index == 99) index = parent.children.size + 1
    } else if (index == 99) index = plan.topGroups.size + 1
    // 更新老的课程组// 更新老的课程组
    if (group.persisted) {
      if ((parent != null && oldParent != null && !(parentId.get == oldParent.id))
        || (parent == null && oldParent != null) || (parent != null && oldParent == null) || index != group.index) {
        planService.move(group, parent, index)
      } else {
        entityDao.saveOrUpdate(group)
      }
    } else { // 保存新的课程组
      group.indexno = "--"
      planService.addCourseGroupToPlan(group, parent, plan)
      planService.move(group, parent, index)
    }

    redirect("groups", s"plan.id=${plan.id}&courseGroup.id=${group.id}", "info.save.success")
  }

  def removeGroup(): View = {
    val group = entityDao.get(classOf[ShareCourseGroup], getLongId("courseGroup"))
    val plan = group.plan
    plan.groups.subtractOne(group)
    group.parent foreach { p =>
      p.children.subtractOne(group)
    }
    group.parent = None
    entityDao.saveOrUpdate(plan)
    redirect("groups", "plan.id=" + plan.id, "info.remove.success")
  }

  /**
   * 为修改或新建课程组显示界面
   */
  def groupCourses(): View = {
    given project: Project = getProject

    val group = entityDao.get(classOf[ShareCourseGroup], getLongId("courseGroup"))

    put("plan", group.plan)
    put("courseGroup", group)
    put("departments", project.departments)
    put("stages", entityDao.getAll(classOf[CalendarStage]))
    put("termHelper", new TermHelper)
    forward()
  }

  /** 查询可用课程
   *
   * @return
   */
  def courses(): View = {
    val plan = entityDao.get(classOf[SharePlan], getLongId("plan"))
    val query = OqlBuilder.from(classOf[Course], "course")
    val q = get("q", "")
    if (Strings.isNotEmpty(q)) query.where("course.code like :q or course.name like :q ", "%" + q + "%")
    query.where("course.project =:project", plan.project).where("course.beginOn <= :endOn", plan.endOn)
      .where("course.endOn is null or :beginOn <= course.endOn", plan.beginOn)
    val limit = getPageLimit
    query.orderBy(get(Order.OrderStr, "course.name"))
    query.limit(limit.pageIndex, 10)
    put("courseList", entityDao.search(query))
    put("plan", plan)
    forward()
  }

  /**
   * 添加培养计划中的课程
   */
  def saveCourse(): View = {
    val group = entityDao.get(classOf[ShareCourseGroup], getLongId("planCourse.group"))
    val plan = group.plan
    val planCourse = populateEntity(classOf[SharePlanCourse], "planCourse")
    val terms = get("planCourse.terms", "")
    planCourse.terms = Terms(terms)
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id
    if (planCourse.persisted) {
      if (group.planCourses.exists(x => x.course == planCourse.course && planCourse.id != x.id)) {
        return redirect("groups", extra, "课程重复")
      }
      planService.updatePlanCourse(planCourse, group)
    } else {
      if (group.planCourses.exists(_.course == planCourse.course)) {
        return redirect("groups", extra, "课程重复")
      }
      planService.addPlanCourse(planCourse, group)
    }
    redirect("groups", extra, "info.save.success")
  }

  def removeCourse(): View = {
    val planCourses = entityDao.find(classOf[SharePlanCourse], getLongIds("planCourse"))
    planCourses foreach { pc =>
      planService.removePlanCourse(pc, pc.group)
    }
    val group = planCourses.head.group
    redirect("groups", s"plan.id=${group.plan.id}&courseGroup.id=${group.id}", "info.save.success")
  }

  def batchAddForm(): View = {
    val group = entityDao.get(classOf[ShareCourseGroup], getLongId("courseGroup"))
    put("courseGroup", group)
    put("plan", group.plan)
    var codes = get("courseCodes", "")
    codes = codes.replaceAll("[\\s;，；]", ",").replaceAll(",,", ",")
    if (Strings.isNotBlank(codes)) {
      val courses = entityDao.findBy(classOf[Course], "code" -> Strings.split(codes), "project" -> getProject)
      put("courses", courses)
    }
    forward()
  }

  def batchAddCourses(): View = {
    val courseIds = getLongIds("course")
    val group = entityDao.get(classOf[ShareCourseGroup], getLongId("courseGroup"))

    val plan = group.plan
    var errorNum: Int = 0
    val allCourses = plan.planCourses.map(_.course).toSet
    for (courseId <- courseIds) {
      val planCourse = new SharePlanCourse
      val terms = get("course." + courseId + ".terms", "")
      planCourse.terms = Terms(terms)
      planCourse.group = group
      val course = entityDao.get(classOf[Course], courseId)
      planCourse.course = course

      if (allCourses.contains(planCourse.course)) {
        errorNum += 1
      } else {
        planService.addPlanCourse(planCourse, group)
      }
    }
    entityDao.saveOrUpdate(plan)
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id
    redirect("groups", extra, "添加 " + courseIds.length + " 成功 " + (courseIds.length - errorNum) + " 失败 " + errorNum)
  }

  def batchEditForm(): View = {
    val group = entityDao.get(classOf[ShareCourseGroup], getLongId("courseGroup"))
    put("courseGroup", group)
    put("plan", group.plan)
    val planCourses = entityDao.find(classOf[SharePlanCourse], getLongIds("planCourse"))
    put("planCourses", planCourses)
    forward()
  }

  def batchEditCourses(): View = {
    val planCourses = entityDao.find(classOf[SharePlanCourse], getLongIds("planCourse"))
    val group = entityDao.get(classOf[ShareCourseGroup], getLongId("courseGroup"))

    val plan = group.plan
    var errorNum: Int = 0
    val allCourses = plan.planCourses.map(_.course).toSet
    planCourses foreach { pc =>
      val terms = get("planCourse." + pc.id + ".terms", "")
      pc.terms = Terms(terms)
    }
    entityDao.saveOrUpdate(plan)
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id
    redirect("groups", extra, "修改成功")
  }

}

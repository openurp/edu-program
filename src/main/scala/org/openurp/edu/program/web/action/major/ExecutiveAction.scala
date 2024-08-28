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

package org.openurp.edu.program.web.action.major

import org.beangle.commons.collection.{Collections, Order}
import org.beangle.commons.lang.Strings
import org.beangle.commons.lang.time.WeekState
import org.beangle.data.dao.OqlBuilder
import org.beangle.ems.app.Ems
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.{Course, Major, Terms}
import org.openurp.base.model.{AuditStatus, CalendarStage, Project}
import org.openurp.code.edu.model.*
import org.openurp.code.std.model.StdType
import org.openurp.edu.clazz.domain.NumSeqParser
import org.openurp.edu.program.model.*
import org.openurp.edu.program.service.*
import org.openurp.edu.service.Features
import org.openurp.starter.web.support.ProjectSupport

import java.time.LocalDate

/** 执行计划维护
 */
class ExecutiveAction extends RestfulAction[ExecutivePlan], ProjectSupport {

  var planService: PlanService = _

  override protected def simpleEntityName: String = "plan"

  override def indexSetting(): Unit = {
    given project: Project = getProject

    val departmentList = getDeparts
    put("departments", departmentList)
    put("levels", project.levels)
    put("educationTypes", getCodes(classOf[EducationType]))

    put("stdTypes", getCodes(classOf[StdType]))
    val query = OqlBuilder.from(classOf[Major], "m")
    query.where("m.project=:project", project)
    query.where("exists(from m.journals as mj where mj.depart in(:departs))", departmentList)
    query.orderBy("m.code")
    val majors = entityDao.search(query)
    put("majors", majors)
    put("statuses", List(AuditStatus.Submited, AuditStatus.PassedByDepart, AuditStatus.RejectedByDepart, AuditStatus.Passed, AuditStatus.Rejected))
    super.indexSetting()
  }

  override protected def getQueryBuilder: OqlBuilder[ExecutivePlan] = {
    val q = super.getQueryBuilder
    val project = getProject
    put("displayEducationType", project.eduTypes.size > 1)
    queryByDepart(q, "plan.department")
    getBoolean("fake.valid").foreach { active =>
      if (active) {
        q.where("(" + q.alias + ".program.endOn >= :now)", LocalDate.now())
      } else {
        q.where(" (" + q.alias + ".program.endOn <= :now)", LocalDate.now())
      }
    }
    q.where("plan.program.project=:project", project)
  }

  def groups(): View = {
    val plan = entityDao.get(classOf[ExecutivePlan], getLongId("plan"))
    getLong("courseGroup.id") foreach { groupId =>
      put("activeGroup", entityDao.get(classOf[ExecutiveCourseGroup], groupId))
    }
    put("plan", plan)
    put("program", plan.program)
    forward()
  }

  def editGroup(): View = {
    val planId = getLongId("plan")
    val plan = entityDao.get(classOf[ExecutivePlan], planId)

    given project: Project = plan.program.project

    val unusedCourseTypeList = getCodes(classOf[CourseType])
    val group = getLong("courseGroup.id") match
      case None =>
        val ng = new ExecutiveCourseGroup
        ng.indexno = "99"
        ng
      case Some(gid) =>
        entityDao.get(classOf[ExecutiveCourseGroup], gid)
    put("courseGroup", group)
    val termCredits = Collections.newMap[Integer, String]
    val termCreditArray: Array[String] = Strings.split(group.termCredits)
    for (i <- termCreditArray.indices) {
      termCredits.put(i + 1, termCreditArray(i))
    }
    put("unusedCourseTypeList", unusedCourseTypeList)
    put("parentCourseGroupList", plan.groups)
    put("termCredits", termCredits)
    put("ranks", getCodes(classOf[CourseRank]))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("stages", entityDao.getAll(classOf[CalendarStage]))
    put("plan", plan)
    forward()
  }

  def saveGroup(): View = {
    val plan = entityDao.get(classOf[ExecutivePlan], getLongId("plan"))

    given project: Project = plan.program.project

    val group = populateEntity(classOf[ExecutiveCourseGroup], "courseGroup")
    val oldParent = group.parent.orNull
    val parentId = getLong("newParentId")
    var parent: CourseGroup = null
    var index = getInt("index", 0)
    if (parentId.nonEmpty) {
      parent = entityDao.get(classOf[ExecutiveCourseGroup], parentId.get)
      if (index == 99) index = parent.children.size + 1
    } else if (index == 99) index = plan.topGroups.size + 1
    if (group.rank.nonEmpty && group.rank.get.id != CourseRank.Compulsory) {
      var terms = ","
      var termCredits = ","
      for (i <- 1 until plan.program.startTerm) {
        termCredits += "0,"
      }
      for (i <- plan.program.startTerm.intValue to plan.program.endTerm) {
        if (getBoolean("term_" + i, false)) terms += (i + ",")
        termCredits += (get("credit_" + i, "") + ",")
      }
      group.termCredits = termCredits
      group.terms = Terms(terms)

      val teachingNatures = getCodes(classOf[TeachingNature])
      val hours = Collections.newMap[TeachingNature, Int]
      teachingNatures foreach { ht =>
        getInt("creditHour" + ht.id) foreach { creditHour =>
          hours.put(ht, creditHour)
        }
      }
      group.hourRatios = hours.map(x => s"${x._1.id}:${x._2}").toSeq.sorted.mkString(",")
    } else {
      if (null == group.hourRatios) {
        group.hourRatios = ""
      }
      if (Strings.isBlank(group.termCredits)) {
        var termCredits = ","
        for (i <- 1 until plan.program.startTerm) {
          termCredits += "0,"
        }
        for (i <- plan.program.startTerm.intValue to plan.program.endTerm) {
          termCredits += "0,"
        }
        group.termCredits = termCredits
      }
    }
    // 更新老的课程组// 更新老的课程组
    if (group.persisted) {
      if ((parent != null && oldParent != null && !(parentId.get == oldParent.id)) || (parent == null && oldParent != null) || (parent != null && oldParent == null) || index != group.index())
        planService.move(group, parent, index)
    } else { // 保存新的课程组
      group.indexno = "--"
      planService.addCourseGroupToPlan(group, parent, plan)
      planService.move(group, parent, index)
    }

    planService.statPlanCredits(plan)
    redirect("groups", s"plan.id=${plan.id}&courseGroup.id=${group.id}", "info.save.success")
  }

  def removeGroup(): View = {
    val group = entityDao.get(classOf[ExecutiveCourseGroup], getLongId("courseGroup"))
    val plan = group.plan.asInstanceOf[ExecutivePlan]
    plan.groups.subtractOne(group)
    group.parent foreach { p =>
      p.asInstanceOf[ExecutiveCourseGroup].children.subtractOne(group)
    }
    group.parent = None
    entityDao.saveOrUpdate(plan)
    planService.statPlanCredits(plan)
    redirect("groups", "plan.id=" + plan.id, "info.remove.success")
  }

  /**
   * 为修改或新建课程组显示界面
   */
  def groupCourses(): View = {
    given project: Project = getProject

    val group = entityDao.get(classOf[ExecutiveCourseGroup], getLongId("courseGroup"))

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
    val plan = entityDao.get(classOf[ExecutivePlan], getLongId("plan"))
    val program = plan.program
    val query = OqlBuilder.from(classOf[Course], "course")
    val q = get("q", "")
    if (Strings.isNotEmpty(q)) query.where("course.code like :q or course.name like :q ", "%" + q + "%")
    query.where("course.project =:project", program.project).where("course.beginOn <= :endOn", program.endOn)
      .where("course.endOn is null or :beginOn <= course.endOn", program.beginOn)
    val limit = getPageLimit
    query.orderBy(get(Order.OrderStr, "course.name"))
    query.limit(limit.pageIndex, 10)
    put("courseList", entityDao.search(query))
    put("plan", plan)
    forward()
  }

  /** FIXME 没有连接对应
   *
   * @param id
   * @return
   */
  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val plan = entityDao.get(classOf[ExecutivePlan], id.toLong)
    put("plan", plan)

    given project: Project = plan.program.project

    put("displayCreditHour", getConfig(Features.Program.DisplayCreditHour))
    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    put("tags", getCodes(classOf[ProgramCourseTag]))
    put("ems_base", Ems.base)
    forward("info")
  }

  override def editSetting(plan: ExecutivePlan): Unit = {
    given project: Project = plan.program.project

    put("displayCreditHour", getConfig(Features.Program.DisplayCreditHour))
    put("enableLinkCourseInfo", getConfig(Features.Program.LinkCourseEnabled))
    put("natures", getCodes(classOf[TeachingNature]))
    put("tags", getCodes(classOf[ProgramCourseTag]))
    val departs = getDeparts
    put("departments", departs)
    put("termHelper", new TermHelper)
    put("ems_base", Ems.base)
    put("isAdmin", departs.size > 2)
    forward()
  }

  /**
   * 添加培养计划中的课程
   */
  def saveCourse(): View = {
    val group = entityDao.get(classOf[ExecutiveCourseGroup], getLongId("planCourse.group"))
    val plan = group.plan
    val planCourse = populateEntity(classOf[ExecutivePlanCourse], "planCourse")
    val isCompulsory = getBoolean("planCourse.compulsory")
    if (isCompulsory.isEmpty) {
      planCourse.compulsory = false
      group.rank foreach { r =>
        planCourse.compulsory = r.compulsory
      }
    }
    val terms = get("planCourse.terms", "")
    planCourse.terms = Terms(terms)
    val weekstate = get("planCourse.weekstate", "")
    if (Strings.isEmpty(weekstate)) planCourse.weekstate = WeekState.Zero
    else planCourse.weekstate = WeekState.of(NumSeqParser.parse(weekstate))
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
    val planCourses = entityDao.find(classOf[ExecutivePlanCourse], getLongIds("planCourse"))
    planCourses foreach { pc =>
      planService.removePlanCourse(pc, pc.group)
    }
    val group = planCourses.head.group
    planService.statPlanCredits(group.plan)
    redirect("groups", s"plan.id=${group.plan.id}&courseGroup.id=${group.id}", "info.save.success")
  }

  def batchAddForm(): View = {
    val group = entityDao.get(classOf[ExecutiveCourseGroup], getLongId("courseGroup"))
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
    val group = entityDao.get(classOf[ExecutiveCourseGroup], getLongId("courseGroup"))

    val plan = group.plan
    var errorNum: Int = 0
    val allCourses = plan.planCourses.map(_.course).toSet
    for (courseId <- courseIds) {
      val planCourse = new ExecutivePlanCourse
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
    planService.statPlanCredits(plan)
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id
    redirect("groups", extra, "添加 " + courseIds.length + " 成功 " + (courseIds.length - errorNum) + " 失败 " + errorNum)
  }

  def batchEditForm(): View = {
    val group = entityDao.get(classOf[ExecutiveCourseGroup], getLongId("courseGroup"))
    put("courseGroup", group)
    put("plan", group.plan)
    val planCourses = entityDao.find(classOf[ExecutivePlanCourse], getLongIds("planCourse"))
    put("planCourses", planCourses)
    forward()
  }

  def batchEditCourses(): View = {
    val planCourses = entityDao.find(classOf[ExecutivePlanCourse], getLongIds("planCourse"))
    val group = entityDao.get(classOf[ExecutiveCourseGroup], getLongId("courseGroup"))

    val plan = group.plan
    var errorNum: Int = 0
    val allCourses = plan.planCourses.map(_.course).toSet
    planCourses foreach { pc =>
      val terms = get("planCourse." + pc.id + ".terms", "")
      pc.terms = Terms(terms)
    }
    entityDao.saveOrUpdate(plan)
    planService.statPlanCredits(plan)
    val extra = "&courseGroup.id=" + group.id + "&plan.id=" + plan.id
    redirect("groups", extra, "修改成功")
  }

  def diff(): View = {
    val ep = entityDao.get(classOf[ExecutivePlan], getLongId("plan"))
    val mp = entityDao.findBy(classOf[MajorPlan], "program", ep.program).head
    put("left", ep)
    put("right", mp)
    put("diffResults", planService.diff(ep, mp))
    put("termHelper", new TermHelper)
    forward()
  }
}

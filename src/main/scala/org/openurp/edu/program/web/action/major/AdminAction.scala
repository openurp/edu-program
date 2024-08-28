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

import com.google.gson.Gson
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.{Direction, Major}
import org.openurp.base.model.{AuditStatus, Project}
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.{Certificate, Degree, EducationType}
import org.openurp.code.std.model.StdType
import org.openurp.edu.program.model.{ExecutivePlan, MajorPlan, Program, ProgramDoc}
import org.openurp.edu.program.service.{PlanService, ProgramNamingHelper}
import org.openurp.edu.program.web.helper.ProgramInfoHelper
import org.openurp.starter.web.support.ProjectSupport

import java.time.{Instant, LocalDate}
import java.util

class AdminAction extends RestfulAction[Program], ProjectSupport {

  var planService: PlanService = _

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

  override protected def getQueryBuilder: OqlBuilder[Program] = {
    val q = super.getQueryBuilder
    val project = getProject
    put("displayEducationType", project.eduTypes.size > 1)
    queryByDepart(q, "program.department")
    getBoolean("fake.valid").foreach { active =>
      if (active) {
        q.where("(" + q.alias + ".endOn >= :now)", LocalDate.now())
      } else {
        q.where(" (" + q.alias + ".endOn <= :now)", LocalDate.now())
      }
    }
    q.where("program.project=:project", project)
  }

  override protected def editSetting(program: Program): Unit = {
    given project: Project = getProject

    val departs = getDeparts
    val query = OqlBuilder.from(classOf[Major], "m")
    query.where("m.project=:project", project)
    query.where("exists(from m.journals as mj where mj.depart in(:departs))", departs)
    query.orderBy("m.code")
    val majors = entityDao.search(query)

    val query2 = OqlBuilder.from(classOf[Direction], "m")
    query2.where("m.project=:project", project)
    query2.where("exists(from m.journals as mj where mj.depart in(:departs))", departs)
    query2.orderBy("m.code")
    val directions = entityDao.search(query)

    put("grades", getGrades(project))
    put("departs", departs)
    put("majors", majors)
    put("directions", directions)
    put("project", project)

    if (program.persisted) {
      put("docs", entityDao.findBy(classOf[ProgramDoc], "program", program))
      entityDao.findBy(classOf[MajorPlan], "program", program).headOption match
        case Some(plan) => put("plan", plan)
        case None => val plan = new MajorPlan(program)
          entityDao.saveOrUpdate(plan)
          put("plan", plan)
    }
    put("degrees", getCodes(classOf[Degree]))
    put("certificates", getCodes(classOf[Certificate]))

    super.editSetting(program)
  }

  private def getGrades(project: Project) = {
    val query = OqlBuilder.from(classOf[Grade], "g")
    query.where("g.project=:project", project)
    query.orderBy("g.code desc")
    entityDao.search(query)
  }

  override protected def saveAndRedirect(program: Program): View = {
    val autoname = getBoolean("autoname", true)
    if (autoname) {
      program.name = ProgramNamingHelper(entityDao).name(program.grade, program.major, program.direction)
    }
    program.updatedAt = Instant.now
    program.project = getProject
    program.degreeCertificates.clear()
    program.degreeCertificates.addAll(entityDao.find(classOf[Certificate], getIntIds("degreeCertificate")))
    entityDao.saveOrUpdate(program)

    getLong("copyFrom.id") match
      case Some(id) =>
        val copyForm = entityDao.get(classOf[Program], id)
        entityDao.findBy(classOf[MajorPlan], "program", copyForm).foreach { p =>
          if entityDao.findBy(classOf[MajorPlan], "program", program).isEmpty then
            val plan = new MajorPlan(program, p)
            entityDao.saveOrUpdate(plan)
        }
        entityDao.findBy(classOf[ProgramDoc], "program", copyForm) foreach { d =>
          val doc = new ProgramDoc(program, d)
          entityDao.saveOrUpdate(doc)
        }
      case None =>
        if entityDao.findBy(classOf[MajorPlan], "program", program).isEmpty then
          val plan = new MajorPlan(program)
          entityDao.saveOrUpdate(plan)

    super.saveAndRedirect(program)
  }

  def duration(): View = {
    val response = ActionContext.current.response
    val majorId = get("majorId", 0L)
    val levelId = get("levelId", 0)
    val start = getDate("start").get
    var duration: Option[Float] = None
    entityDao.find(classOf[Major], majorId) foreach { major =>
      major.schoolLengths.find(x => x.level.id == levelId).foreach { s => duration = Some(s.normal) }
    }
    if (duration.isEmpty) duration = Some(4)
    val d = duration.get
    val mnum = (d * 12).toInt
    val result = new util.HashMap[String, Any]
    result.put("endOn", start.plusMonths(mnum).toString)
    result.put("duration", d)
    response.setContentType("text/plain;charset=UTF-8")
    response.getWriter.write(new Gson().toJson(result))
    response.getWriter.close()
    null
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val program = entityDao.get(classOf[Program], id.toLong)
    val helper = new ProgramInfoHelper(entityDao, configService, codeService)
    helper.prepareData(program)
    forward()
  }

  def report(): View = {
    redirect(to(classOf[ReviseAction], "report", "program.id=" + getLongId("program")), "")
  }

  /** 审核方案
   *
   * @return
   */
  def audit(): View = {
    val programs = entityDao.find(classOf[Program], getLongIds("program"))
    val passed = getBoolean("passed", false)
    programs foreach { program =>
      val status = if passed then AuditStatus.Passed else AuditStatus.Rejected
      program.status = status
    }
    entityDao.saveOrUpdate(programs)
    redirect("search", "审核成功")
  }

  /** 生成执行计划
   *
   * @return
   */
  def gen(): View = {
    val programs = entityDao.find(classOf[Program], getLongIds("program"))
    val force = getBoolean("force", false)
    programs foreach { program =>
      entityDao.findBy(classOf[MajorPlan], "program", program) foreach { majorPlan =>
        val eps = entityDao.findBy(classOf[ExecutivePlan], "program", program)
        if (eps.isEmpty) {
          val ep = new ExecutivePlan(majorPlan)
          entityDao.saveOrUpdate(ep)
        } else {

        }
      }
    }
    redirect("search", "生成成功")
  }

  override protected def removeAndRedirect(programs: Seq[Program]): View = {
    val removables = programs.filter(_.status != AuditStatus.Passed)
    val docs = entityDao.findBy(classOf[ProgramDoc], "program", removables)
    val plans = entityDao.findBy(classOf[MajorPlan], "program", removables)
    entityDao.remove(docs)
    entityDao.remove(plans)
    super.removeAndRedirect(removables)
  }

  def copyPrompt(): View = {
    given project: Project = getProject

    val departs = getDeparts
    val query = OqlBuilder.from(classOf[Major], "m")
    query.where("m.project=:project", project)
    query.where("exists(from m.journals as mj where mj.depart in(:departs))", departs)
    query.orderBy("m.code")
    val majors = entityDao.search(query)

    val query2 = OqlBuilder.from(classOf[Direction], "m")
    query2.where("m.project=:project", project)
    query2.where("exists(from m.journals as mj where mj.depart in(:departs))", departs)
    query2.orderBy("m.code")
    val directions = entityDao.search(query)

    put("grades", getGrades(project))
    put("departs", departs)
    put("majors", majors)
    put("directions", directions)
    put("project", project)

    put("degrees", getCodes(classOf[Degree]))
    put("certificates", getCodes(classOf[Certificate]))

    val copyFrom = entityDao.get(classOf[Program], getLongId("program"))
    put("program", new Program(copyFrom))
    put("copyFrom", copyFrom)
    forward()
  }

  def restat(): View = {
    val programs = entityDao.find(classOf[Program], getLongIds("program"))
    programs foreach { program =>
      entityDao.findBy(classOf[MajorPlan], "program", program) foreach { plan =>
        planService.statPlanCredits(plan)
      }
    }
    redirect("search", "统计成功")
  }
}

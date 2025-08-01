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

package org.openurp.edu.program.web.helper

import org.beangle.data.dao.EntityDao
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.webmvc.context.ActionContext
import org.openurp.base.model.Project
import org.openurp.base.service.{Feature, ProjectConfigService}
import org.openurp.code.Code
import org.openurp.code.edu.model.{ProgramCourseTag, TeachingNature}
import org.openurp.code.service.CodeService
import org.openurp.edu.program.util.{PlanCategoryStat, TermHelper}
import org.openurp.edu.program.model.{MajorPlan, Program, ProgramDoc}
import org.openurp.starter.web.helper.ProjectProfile

class ProgramInfoHelper(entityDao: EntityDao, configService: ProjectConfigService, codeService: CodeService) {
  def prepareData(program: Program): Unit = {
    put("program", program)

    given project: Project = program.project

    val plan = entityDao.findBy(classOf[MajorPlan], "program", program).head
    put("plan", plan)
    put("doc", entityDao.findBy(classOf[ProgramDoc], "program", program).headOption)
    ProjectProfile.set(project)
    val natures = getCodes(classOf[TeachingNature])
    put("natures", natures)
    put("tags", getCodes(classOf[ProgramCourseTag]))
    put("termHelper", TermHelper)
    val stat = PlanCategoryStat.stat(plan, natures)
    put("stat", stat)
  }

  def getCodes[T <: Code](clazz: Class[T])(using project: Project): collection.Seq[T] = {
    codeService.get(clazz)
  }

  protected def getConfig(f: Feature)(using project: Project): Any = {
    configService.get[Any](project, f)
  }

  private def put(name: String, v: Any): Unit = {
    ActionContext.current.attribute(name, v)
  }
}

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

package org.openurp.edu.program.web.action

import org.beangle.cdi.bind.BindModule
import org.openurp.edu.program.service.impl.*
import org.openurp.edu.program.service.lixin.{EnglishCourseCountPlanChecker, MajorOptionalPlanChecker, StagePlanChecker}
import org.openurp.edu.program.web.action.major.PlanAction

class DefaultModule extends BindModule {
  override protected def binding(): Unit = {

    bind(classOf[info.ExecutiveAction])
    bind(classOf[info.ProgramAction])

    bind(classOf[major.AdminAction])
    bind(classOf[major.DocAction])
    bind(classOf[major.PlanAction])
    bind(classOf[major.ReviseAction])
    bind(classOf[major.AuditAction])
    bind(classOf[major.ReviewAction])
    bind(classOf[major.PrerequisiteAction])
    bind(classOf[major.StatAction])
    bind(classOf[major.ExecutiveAction])

    bind(classOf[exempt.CourseAction])
    bind(classOf[exempt.StdAction])

    bind(classOf[alt.MajorAction])
    bind(classOf[alt.StdAction])
    bind(classOf[alt.ApplyAction])
    bind(classOf[alt.CourseTypeAction])

    bind(classOf[PlanServiceImpl])
    bind(classOf[DefaultProgramChecker])
      .property("planCheckers",
        list(ref("PlanChecker.optionalCreditHour"),
          ref("PlanChecker.creditStat"),
          ref("PlanChecker.englishCourseCount"),
          ref("PlanChecker.majorOptional"),
          ref("PlanChecker.stage"),
          ref("PlanChecker.courseHour"),
          ref("PlanChecker.terms")
        )
      ).property("docCheckers",
        list(
          ref("DocChecker.majorCourse")
        )
      )

    bind("PlanChecker.majorOptional", classOf[MajorOptionalPlanChecker])
    bind("PlanChecker.englishCourseCount", classOf[EnglishCourseCountPlanChecker])
    bind("PlanChecker.creditStat", classOf[CreditStatPlanChecker])
    bind("PlanChecker.optionalCreditHour", classOf[OptionalCreditHourPlanChecker])
    bind("PlanChecker.stage", classOf[StagePlanChecker])
    bind("PlanChecker.courseHour", classOf[CourseHourPlanChecker])
    bind("PlanChecker.terms", classOf[TermsPlanChecker])

    bind("DocChecker.majorCourse", classOf[MajorCourseDocChecker])
  }

}

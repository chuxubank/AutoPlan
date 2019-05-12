//
//  Project.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/11.
//  Copyright © 2019 Misaka. All rights reserved.
//

import Foundation

extension Project {
    var doneTasksCount: Int {
        var count = 0
        let tasks = self.tasks as! Set<Task>
        for task in tasks {
            if task.isDone {
                count += 1
            }
        }
        return count
    }
}

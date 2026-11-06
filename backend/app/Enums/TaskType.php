<?php

namespace App\Enums;

enum TaskType: string
{
    case QuickTask = 'quick_task';
    case ProjectTask = 'project_task';
}

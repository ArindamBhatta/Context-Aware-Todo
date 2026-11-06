<?php

namespace App\Enums;

enum UrgencyLevel: string
{
    case NotUrgentImportant = 'not_urgent_important';
    case UrgentNotImportant = 'urgent_not_important';
    case UrgentImportant = 'urgent_important';
    case NotUrgentNotImportant = 'not_urgent_not_important';
}

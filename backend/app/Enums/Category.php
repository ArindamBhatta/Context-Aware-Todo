<?php

namespace App\Enums;

enum Category: string
{
    case Office = 'office';
    case Health = 'health';
    case Study = 'study';
    case Finance = 'finance';
    case Home = 'home';
    case Personal = 'personal';
    case Career = 'career';
    case Self = 'self';
    case Leisure = 'leisure';
    case Fun = 'fun';
}

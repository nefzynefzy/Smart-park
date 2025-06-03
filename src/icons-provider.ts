// src/icons-provider.ts

import { Provider } from '@angular/core';
import { NZ_ICONS } from 'ng-zorro-antd/icon';
import {
  DashboardOutline,
  UserOutline,
  LockOutline
} from '@ant-design/icons-angular/icons';

const icons = [DashboardOutline, UserOutline, LockOutline];

export function provideNzIcons(): Provider {
  return {
    provide: NZ_ICONS,
    useValue: icons
  };
}

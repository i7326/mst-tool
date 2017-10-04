import {trigger, stagger, animate, style, group, query as q, transition, keyframes} from '@angular/animations';
const query = (s,a,o={optional:true})=>q(s,a,o);

export const headerTransition = trigger('headerTransition', [
  transition(':leave', [
    query('.header',  [
          style({ transform: 'translateX(100%)' }),
          animate('500ms cubic-bezier(.75,-0.48,.26,1.52)',
            style({ transform: 'translateX(0%)' })),
        ])
  ]),
  transition(':enter', [
      query('.header', [
          style({ transform: 'translateX(0%)' }),
          animate('500ms cubic-bezier(.75,-0.48,.26,1.52)'),
            style({ transform: 'translateX(-100%)' })
        ])
  ])
]);

import { Component } from '@angular/core';

@Component({
  selector: 'tree-component',
  templateUrl: './tree.component.html',
  styleUrls: ['./tree.component.css']
})

export class TreeComponent {
  onEvent($event) {
    alert("Test");
    console.log($event)
  }
  nodes = [
    {
      expanded: true,
      name: 'Destination Computer',
      subTitle: 'the root',
      children: [
        {
          name: 'My Documents', children: [
            { name: 'My Pictures' }
          ]
        },
        {
          name: 'Program Files', children: [
            { name: 'Common Files' }
          ]
        },
        {
          name: 'Windows', children: [
            {
              name: 'Profiles', children: [
                {
                  name: 'All Users', children: [
                    { name: 'Application Data' },
                  ]
                },
                { name: 'Desktop' },
                {
                  name: 'Local Settings', children: [
                    { name: 'Application Data' },
                  ]
                },
              ]
            },
            { name: 'Temp' }
          ]
        },
      ]
    }
  ];

  customTemplateStringOptions = {
    //displayField: 'subTitle',
    isExpandedField: 'expanded',
    idField: 'uuid',
    nodeHeight: 23,
    allowDrag: true,
    useVirtualScroll: true
  }

  

}

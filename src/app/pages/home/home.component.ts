import { Component, OnInit } from '@angular/core';
import { MdSnackBar } from '@angular/material';
import { PSService } from '../../ps.service';
import { remote, shell } from 'electron';
import { FormControl } from '@angular/forms';
import { join } from 'path';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})

export class HomeComponent implements OnInit {
  Dialog = remote.dialog;
  Msi: any;
  MstPath: any = {};
  Filename: string;
  HeaderTextArray: string[] = ['1. Select MSI', '2. Verify Package Name', '3. Generate MST'];
  HeaderText: string;
  constructor(private PsShell: PSService, private Snackbar: MdSnackBar) { }

  ngOnInit() {
    this.HeaderText = this.HeaderTextArray[0];
    this.Msi = {
      checkBoxValue: false
    };
    this.Filename = '';
  }

  generatePackageName(msi) {
    let packageName = '';
    for (let x in msi) {
      packageName += (x == 'ProductLanguage' ? msi[x].substr(0, 2).toUpperCase() : msi[x].replace(/[^._A-Za-z0-9]/g, '')) + '_';
    }
    return packageName;
  }

  generateMST(path, packageName, checkboxValue) {
    if (!checkboxValue) return false;
    this.Snackbar.dismiss();
    this.Msi.activeSetup
    this.PsShell.run('generate-mst.ps1', [{ Path: `${join(path)}` }, { PackageName: packageName },{ ActiveSetup: (this.Msi.activeSetup) ? true : false}])
      .subscribe(
      output => this.MstPath = JSON.parse(output),
      error => {
        this.Dialog.showErrorBox("Error Creating MST", "Error Creating MST!");
      },
      () => {
        if(this.MstPath.Error) {
          this.Dialog.showErrorBox("Error Creating MST", `${this.MstPath.Error}!`);
          return false;
        }
        if (this.MstPath) {
          this.openSnackbar(this.MstPath);
        }
      });
  }
  checkboxFunction(event) {
    this.HeaderText = (event.checked) ? this.HeaderTextArray[2] : this.HeaderTextArray[1];
  }

  packageNameTextbox() {
    if (this.validatePackageName()) this.Msi.checkBoxValue = false;
  }

  browseMsi() {
    this.ngOnInit();
    this.Snackbar.dismiss();
    this.Dialog.showOpenDialog(remote.getCurrentWindow(), {
      filters: [
        { name: 'Microsoft Installer', extensions: ['msi'] }
      ]
    },
      (filename) => {
        if (filename) {
          this.Filename = filename[0];
          this.PsShell.run('get-msiproperty.ps1', [{ Path: `${join(this.Filename)}` }])
            .subscribe(
            output => this.Msi = JSON.parse(output),
            error => {
              this.Dialog.showErrorBox("Error Opening MSI", "Error Opening MSI!");
            },
            () => {
              if(this.Msi.Error) {
                this.Dialog.showErrorBox("Error Opening MSI", `${this.Msi.Error}!`);
                return false;
              }
              if (this.Msi) {
                switch (this.Msi.ProductLanguage) {
                  case "1033": {
                    this.Msi.ProductLanguage = "English";
                    break;
                  }
                }
                this.Msi.PackageName = this.generatePackageName(this.Msi) + '01';
                this.HeaderText = this.HeaderTextArray[1];
              }
            });
        }
      });
  }

  openSnackbar(mstPath) {
    let snackBarRef = this.Snackbar.open('MST Created !', 'Open Folder');
    snackBarRef.onAction().subscribe(() => {
      shell.showItemInFolder(mstPath);
      this.ngOnInit();
    });
  }

  validatePackageName(): boolean {
    if (this.Msi.PackageName) return !!(this.Msi.PackageName.match('[^._A-Za-z0-9]'));
  }

}

import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { MdSnackBar } from '@angular/material';
import { PSService } from '../../ps.service';
import { remote, shell } from 'electron';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {
  dialog = remote.dialog;
  msi: any = {};
  filename: string;
  errorMessage: string;
  checkBoxValue: boolean = false;
  showSpinner: boolean = false;
  headerTextArray: string[] = ['1. Select MSI','2. Verify Package Name','3. Generate MST'];
  headerText: string;
  constructor(private PSShell: PSService, private ref: ChangeDetectorRef, private snackbar: MdSnackBar) { }

  ngOnInit() {

    //console.log(this.app.getAppPath());
    //this.Shell.test([{Path:filename}]);
  }

  generatePackageName(msi) {
    let packagename = '';
    for (let x in msi) {
      packagename += (x == 'ProductLanguage' ? msi[x].substr(0, 2).toUpperCase() : msi[x].replace(/\s/g, '')) + '_';
    }
    return packagename;
  }

  generateMST(path, packageName, checkboxValue) {
    if (!checkboxValue) return false;
    this.snackbar.dismiss();
    this.showSpinner = true;
    this.PSShell.run('generate-mst', [{ Path: path }, { PackageName: packageName }])
      .subscribe(
      output => this.msi.MSTPath = JSON.parse(output),
      error => this.errorMessage = <any>error,
      () => {
        this.showSpinner = false;
        if (this.msi.MSTPath) {
          this.openSnackbar(this.msi.MSTPath);
        }
      });
  }
  checkboxFunction(event) {
      this.headerText = (event.checked) ? this.headerTextArray[2] : this.headerTextArray[1];
  }

  browseMsi() {
    this.dialog.showOpenDialog(remote.getCurrentWindow(),{
      filters: [
        { name: 'Microsoft Installer', extensions: ['msi'] }
      ]
    },
      (filename) => {
        if (filename) {
          this.filename = filename[0];
          this.PSShell.run('get-msiproperty', [{ Path: filename[0] }])
            .subscribe(
            output => this.msi = JSON.parse(output),
            error => {
              this.dialog.showErrorBox("Error Creating MST", "Error Creating MST!");
            },
            () => {
              if (this.msi) {
                switch (this.msi.ProductLanguage) {
                  case "1033": {
                    this.msi.ProductLanguage = "English";
                    break;
                  }
                }
                this.msi.PackageName = this.generatePackageName(this.msi) + '01';
                this.headerText = "2. Verify Package Name";
              }
              this.ref.detectChanges();
              setTimeout(()=>{
                this.ref.detectChanges();
              }, 50);
            });
        }
      });
  }

  openSnackbar(mstPath) {
    let snackBarRef = this.snackbar.open('MST Created !', 'Open Folder');
    snackBarRef.onAction().subscribe(() => {
      shell.showItemInFolder(mstPath);
      this.msi = {};
    });
  }

}

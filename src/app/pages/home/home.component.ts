import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { MdSnackBar } from '@angular/material';
import { PSService } from '../../ps.service';
import { remote,shell } from 'electron';


@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {
  private app = remote.app;
  private dialog = remote.dialog;
  private root = this.app.getAppPath();
  msi: any = {};
  filename: string;
  errorMessage: string;
  checkboxValue: boolean = false;
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

  generateMST(path,packageName,checkboxValue) {
    if(!checkboxValue) return false;
    this.PSShell.run(this.root.concat('/scripts/generate-mst.ps1'), [{Path: path}, {PackageName: packageName}])
      .subscribe(
      output => this.msi.MSTPath = JSON.parse(output),
      error => this.errorMessage = <any>error,
      () => {
        if (this.msi.MSTPath) {
          this.openSnackbar(this.msi.MSTPath);
        }
      });
    }

  browseMsi() {
    this.dialog.showOpenDialog({
      filters: [
        { name: 'Microsoft Installer', extensions: ['msi'] }
      ]
    },
      (filename) => {
        if (filename) {
          this.filename = filename[0];
          this.PSShell.run(this.root.concat('/scripts/get-msiproperty.ps1'), [{ Path: filename[0] }])
            .subscribe(
            output => this.msi = JSON.parse(output),
            error => this.errorMessage = <any>error,
            () => {
              if (this.msi) {
                switch (this.msi.ProductLanguage) {
                  case "1033": {
                    this.msi.ProductLanguage = "English";
                    break;
                  }
                }
                this.msi.PackageName = this.generatePackageName(this.msi) + '01';
              }
              this.ref.detectChanges();
            }
            );
        }
      });
  }

  openSnackbar(mstPath) {
    let snackBarRef = this.snackbar.open('MST Created !', 'Open Folder');
    snackBarRef.onAction().subscribe(() => {
      console.log(mstPath);
    });
  }

}

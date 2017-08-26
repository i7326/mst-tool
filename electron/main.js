const electron = require('electron')

const path = require('path')

const fs = require('fs')

const rimraf = require('rimraf')

const env = require('process').env;

const temp = fs.mkdtempSync(path.join(`${env.Tmp}/`))

// Module to control application life.
const app = electron.app
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow = null

const isSecondInstance = app.makeSingleInstance((commandLine, workingDirectory) =>{
  if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore()
      mainWindow.focus()
    }
return true})

if(isSecondInstance){ app.quit() }

app.TempPath = function() {
  return temp;
}

function createWindow() {
  var scriptDir = `${path.join(app.getAppPath(), 'scripts')}`
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 640,
    height: 480,
    resizable: false,
    fullscreen: false,
    show: false
  })

  // and load the index.html of the app.
  mainWindow.loadURL(`file://${__dirname}/index.html`)

  mainWindow.once('ready-to-show', () => {
    mainWindow.show()
  })

  fs.readdir(scriptDir, (err, files) => {
    files.forEach(file => {
      filetream = fs.createWriteStream(path.join(temp, file));
      filetream.write(fs.readFileSync(path.join(scriptDir, file)))
      filetream.end()
    });
  })
  //mainWindow.loadURL(`http://localhost:4200`)
  // Open the DevTools.
  //mainWindow.webContents.openDevTools()



  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function() {

  if (fs.existsSync(temp)) rimraf.sync(temp)

  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function() {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.

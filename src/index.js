const core = require('@actions/core');
const tc = require('@actions/tool-cache');
const exec = require('@actions/exec');
const path = require('path');
const os = require('os');
const fs = require('fs');

async function run() {
  try {
    // Get inputs
    const version = core.getInput('version') || 'v0.2.2';
    
    core.info(`Setting up updater ${version}`);
    
    // Determine platform and architecture
    const platform = getPlatform();
    const arch = getArch();
    
    core.info(`Detected platform: ${platform}, architecture: ${arch}`);
    
    // Check if already in cache
    let cachedPath = tc.find('updater', version, arch);
    
    if (cachedPath) {
      core.info(`Found updater ${version} in tool cache at ${cachedPath}`);
    } else {
      // Download the binary
      const binaryName = platform === 'windows' ? 'updater.exe' : 'updater';
      const artifactName = `updater_${platform}_${arch}${platform === 'windows' ? '.exe' : ''}`;
      const downloadUrl = `https://github.com/mxcd/updater/releases/download/${version}/${artifactName}`;
      
      core.info(`Downloading updater from ${downloadUrl}`);
      
      let downloadPath;
      try {
        downloadPath = await tc.downloadTool(downloadUrl);
      } catch (error) {
        throw new Error(`Failed to download updater from ${downloadUrl}: ${error.message}`);
      }
      
      // Make executable on Unix-like systems
      if (platform !== 'windows') {
        await fs.promises.chmod(downloadPath, '755');
      }
      
      // Create a directory for the tool
      const toolDir = path.join(os.tmpdir(), `updater-${Date.now()}`);
      await fs.promises.mkdir(toolDir, { recursive: true });
      
      // Move the binary to the tool directory
      const binaryPath = path.join(toolDir, binaryName);
      await fs.promises.rename(downloadPath, binaryPath);
      
      // Cache the tool
      cachedPath = await tc.cacheDir(toolDir, 'updater', version, arch);
      core.info(`Cached updater to ${cachedPath}`);
    }
    
    // Add to PATH
    core.addPath(cachedPath);
    core.info(`Added ${cachedPath} to PATH`);
    
    // Set output
    core.setOutput('version', version);
    
    core.info(`Successfully set up updater ${version}`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

function getPlatform() {
  const platform = os.platform();
  
  switch (platform) {
    case 'darwin':
      return 'darwin';
    case 'linux':
      return 'linux';
    case 'win32':
      return 'windows';
    default:
      throw new Error(`Unsupported platform: ${platform}`);
  }
}

function getArch() {
  const arch = os.arch();
  
  switch (arch) {
    case 'x64':
      return 'amd64';
    case 'arm64':
      return 'arm64';
    case 'arm':
      return 'arm';
    case 'ia32':
      return '386';
    default:
      throw new Error(`Unsupported architecture: ${arch}`);
  }
}

run();

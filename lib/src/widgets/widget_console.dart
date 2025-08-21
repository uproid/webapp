import 'package:webapp/src/views/htmler.dart';
import 'package:webapp/src/widgets/wa_string_widget.dart';

class ConsoleWidget implements WaStringWidget {
  @override
  get layout => """
class DebuggerStatusBar {
  constructor() {
    this.isCollapsed = false;
    this.isRunning = true;
    this.startTime = Date.now();
    this.breakpoints = 0;
    this.memory = 0;
    this.createStyles();
    this.createElements();
    this.bindEvents();
    this.logs = [];
  }
  
  createStyles() {
    const styleSheet = document.createElement('style');
    styleSheet.textContent = `
      .wa-console, .wa-console * {
        all: revert;
      }
      .wa-console #debugger-container {
        direction: ltr;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        z-index: 10000;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        transition: transform 0.3s ease;
        background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        box-shadow: 0 -2px 15px rgba(0,0,0,0.3);
        height: 40px;
      }
      
      .wa-console #debugger-container.collapsed {
        transform: translateY(100%);
      }
      
      .wa-console #debugger-container.disconnected {
        background: linear-gradient(135deg, #d32f2f 0%, #b71c1c 100%) !important;
        border-bottom: 2px solid #f44336 !important;
      }
      
      .wa-console #debugger-container.disconnected #debugger-bar {
        border-bottom: 2px solid #f44336;
      }
      
      .wa-console #debugger-toggle {
        padding: 0;
        margin: 0;
        direction: ltr;
        position: fixed;
        bottom: 4px;
        left: 3px;
        z-index: 10001;
        height: 35px;
        width: 35px;
        background: rgba(255,255,255,0.8);
        border: 1px solid #696cff;
        border-radius: 8px;
        color: white;
        cursor: pointer;
        font-size: 11px;
        font-weight: 500;
        transition: all 0.2s ease;
        outline: none;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: flex;
        align-items: center;
        gap: 8px;
        text-align: center;
      }
      
      .wa-console #debugger-toggle:hover {
        background: #FFFFFF;
        box-shadow: 0 6px 20px rgba(0,0,0,0.2);
        border: 2px solid #696cff;
      }
      
      .wa-console #debugger-bar {
        padding: 3px 3px 3px 50px;
        border-bottom: 2px solid #667eea;
      }
      
      .wa-console .debugger-content {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 15px;
      }
      
      .wa-console .debugger-section {
        display: flex;
        align-items: center;
        gap: 12px;
      }
      
      .wa-console  .debugger-status {
        background: rgba(255,255,255,0.1);
        padding: 6px 15px;
        border-radius: 25px;
        color: white;
        font-size: 12px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        letter-spacing: 0.5px;
      }
      
      .wa-console .status-running {
        background: rgba(76, 175, 80, 0.3) !important;
        border: 1px solid #4CAF50;
      }
      
      .wa-console .status-paused {
        background: rgba(255, 193, 7, 0.3) !important;
        border: 1px solid #FFC107;
      }
      
      .wa-console .status-stopped {
        background: rgba(244, 67, 54, 0.3) !important;
        border: 1px solid #F44336;
      }
      
      .wa-console .debugger-btn {
        background: rgba(255,255,255,0.1);
        border: 1px solid rgba(255,255,255,0.2);
        border-radius: 8px;
        color: white;
        padding: 8px 14px;
        cursor: pointer;
        font-size: 11px;
        font-weight: 500;
        transition: all 0.2s ease;
        outline: none;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
      
      .wa-console .debugger-btn:hover {
        background: rgba(255,255,255,0.2);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      }
      
      .wa-console .debugger-btn:active {
        transform: translateY(0px);
      }
      
      .wa-console .debugger-btn.active {
        background: rgba(102, 126, 234, 0.5);
        border-color: #667eea;
        box-shadow: 0 0 10px rgba(102, 126, 234, 0.3);
      }
      
      .wa-console .debugger-info {
        color: rgba(255,255,255,0.85);
        font-size: 11px;
        display: flex;
        align-items: center;
        gap: 20px;
        font-weight: 500;
      }
      
      .wa-console .debugger-info span {
        display: flex;
        align-items: center;
        gap: 6px;
      }
      
      .wa-console .status-indicator {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        display: inline-block;
        box-shadow: 0 0 8px rgba(255,255,255,0.3);
      }
      
      .wa-console .indicator-green { 
        background: #4CAF50; 
        box-shadow: 0 0 8px rgba(76, 175, 80, 0.6);
      }
      .wa-console .indicator-yellow { 
        background: #FFC107; 
        box-shadow: 0 0 8px rgba(255, 193, 7, 0.6);
      }
      .wa-console .indicator-red { 
        background: #F44336; 
        box-shadow: 0 0 8px rgba(244, 67, 54, 0.6);
      }
      
      .wa-console .debugger-notification {
        direction: ltr;
        position: fixed;
        bottom: 70px;
        right: 20px;
        z-index: 10002;
        padding: 12px 18px;
        border-radius: 8px;
        color: white;
        font-size: 12px;
        font-weight: 500;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        backdrop-filter: blur(10px);
      }
      
      .wa-console .notification-success { 
        background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
      }
      .wa-console .notification-warning { 
        background: linear-gradient(135deg, #FF9800 0%, #f57c00 100%);
      }
      .wa-console .notification-error { 
        background: linear-gradient(135deg, #F44336 0%, #d32f2f 100%);
      }
      .wa-console .notification-info { 
        background: linear-gradient(135deg, #2196F3 0%, #1976d2 100%);
      }
      
      /* Console Modal Styles */
      .wa-console .console-modal {
        direction: ltr;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.8);
        z-index: 10003;
        display: flex;
        justify-content: center;
        align-items: center;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
      }
      
      .wa-console .console-modal.active {
        opacity: 1;
        visibility: visible;
      }

      .wa-console .console-modal-content {
        background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
        border-radius: 12px;
        width: 90%;
        max-width: 900px;
        max-height: 80%;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        transform: scale(0.8);
        transition: transform 0.3s ease;
      }

      .wa-console .console-modal.active .console-modal-content {
        transform: scale(1);
      }

      .wa-console .console-modal-header {
        background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
        padding: 15px 20px;
        color: white;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .wa-console .console-modal-title {
        font-size: 16px;
        font-weight: 600;
        margin: 0;
      }
      
      .wa-console .console-modal-close {
        background: none;
        border: none;
        color: white;
        font-size: 24px;
        cursor: pointer;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: background 0.2s ease;
      }
      
      .wa-console .console-modal-close:hover {
        background: rgba(255, 255, 255, 0.2);
      }
      
      .wa-console .console-modal-body {
        padding: 20px;
        max-height: 500px;
        overflow-y: auto;
        color: #ecf0f1;
      }
      
      .wa-console .error-summary {
        background: rgba(231, 76, 60, 0.1);
        border-left: 4px solid #e74c3c;
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 4px;
      }
      
      .wa-console .error-title {
        font-size: 16px;
        font-weight: 600;
        color: #e74c3c;
        margin-bottom: 8px;
      }
      
      .wa-console .error-message {
        font-size: 14px;
        color: #ecf0f1;
        line-height: 1.5;
      }
      
      .wa-console .error-details {
        margin-top: 20px;
      }
      
      .wa-console .error-section {
        margin-bottom: 20px;
      }
      
      .wa-console .error-section-title {
        font-size: 14px;
        font-weight: 600;
        color: #3498db;
        margin-bottom: 10px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }

      .wa-console .error-json {
        background: #1a1a1a;
        border: 1px solid #444;
        border-radius: 6px;
        padding: 15px;
        font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
        font-size: 12px;
        color: #a8e6cf;
        overflow-x: auto;
        white-space: pre-wrap;
        word-wrap: break-word;
      }

      .wa-console .stack-trace {
        background: #2c2c2c;
        border: 1px solid #555;
        border-radius: 6px;
        padding: 15px;
        font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
        font-size: 11px;
        color: #ff6b6b;
        max-height: 200px;
        overflow-y: auto;
        line-height: 1.4;
      }

      .wa-console .error-tabs {
        display: flex;
        border-bottom: 1px solid #444;
        margin-bottom: 15px;
      }

      .wa-console .error-tab {
        padding: 10px 15px;
        background: none;
        border: none;
        color: #bdc3c7;
        cursor: pointer;
        font-size: 12px;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        transition: all 0.2s ease;
      }

      .wa-console .error-tab.active {
        color: #3498db;
        background: rgba(52, 152, 219, 0.1);
        border-bottom: 2px solid #3498db;
      }
      
      .wa-console .error-tab:hover {
        color: #3498db;
        background: rgba(52, 152, 219, 0.05);
      }
      
      .wa-console .tab-content {
        display: none;
      }
      
      .wa-console .tab-content.active {
        display: block;
      }
      
      /* Routes Table Styles */
      .wa-console .routes-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
        background: #1a1a1a;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      }
      
      .wa-console .routes-table th {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 12px 8px;
        text-align: left;
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 2px solid #555;
      }
      
      .wa-console .routes-table td {
        padding: 10px 8px;
        border-bottom: 1px solid #333;
        font-size: 11px;
        color: #ecf0f1;
        vertical-align: top;
      }
      
      .wa-console .routes-table tr:nth-child(even) {
        background: rgba(255,255,255,0.02);
      }
      
      .wa-console .routes-table tr:hover {
        background: rgba(102, 126, 234, 0.1);
      }
      
      .wa-console .method-badge {
        display: inline-block;
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 9px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }
      
      .wa-console .method-get { background: #4CAF50; color: white; }
      .wa-console .method-post { background: #2196F3; color: white; }
      .wa-console .method-put { background: #FF9800; color: white; }
      .wa-console .method-delete { background: #f44336; color: white; }
      .wa-console .method-patch { background: #9C27B0; color: white; }

      .wa-console .type-badge {
        display: inline-block;
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 9px;
        font-weight: 500;
        background: rgba(52, 152, 219, 0.2);
        color: #3498db;
        border: 1px solid #3498db;
      }
      
      .wa-console .auth-indicator {
        display: inline-block;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        margin-right: 6px;
      }
      
      .wa-console .auth-true { background: #4CAF50; }
      .wa-console .auth-false { background: #f44336; }
      
      .wa-console .routes-summary {
        background: rgba(52, 152, 219, 0.1);
        border-left: 4px solid #3498db;
        padding: 12px 15px;
        margin-bottom: 15px;
        border-radius: 4px;
        color: #ecf0f1;
        font-size: 12px;
      }
      
      .wa-console .routes-summary-title {
        font-weight: 600;
        color: #3498db;
        margin-bottom: 5px;
      }
      
      /* Dropdown Menu Styles */
      .wa-console .debugger-dropdown {
        position: relative;
        display: inline-block;
      }
      
      .wa-console .dropdown-toggle {
        background: rgba(255,255,255,0.1);
        border: 1px solid rgba(255,255,255,0.2);
        border-radius: 8px;
        color: white;
        padding: 8px 16px;
        cursor: pointer;
        font-size: 11px;
        font-weight: 500;
        transition: all 0.2s ease;
        outline: none;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: flex;
        align-items: center;
        gap: 8px;
      }
      
      .wa-console .dropdown-toggle:hover {
        background: rgba(255,255,255,0.2);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      }
      
      .wa-console .dropdown-toggle::after {
        content: '▲';
        font-size: 10px;
        transition: transform 0.4s ease;
      }
      
      .wa-console .dropdown-toggle.active::after {
        transform: rotate(180deg);
      }
      
      .wa-console .dropdown-menu {
        position: absolute;
        bottom: 100%;
        right: 0;
        background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
        border: 1px solid rgba(255,255,255,0.1);
        border-radius: 8px;
        min-width: 200px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.3);
        z-index: 1000;
        opacity: 0;
        visibility: hidden;
        transform: translateY(10px);
        transition: all 0.3s ease;
        backdrop-filter: blur(10px);
        margin-bottom: 8px;
      }
      
      .wa-console .dropdown-menu.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
      }
      
      .wa-console .dropdown-section {
        padding: 8px 0;
        border-bottom: 1px solid rgba(255,255,255,0.1);
      }
      
      .wa-console .dropdown-section:last-child {
        border-bottom: none;
      }
      
      .wa-console .dropdown-section-title {
        padding: 6px 16px;
        font-size: 10px;
        font-weight: 600;
        color: rgba(255,255,255,0.6);
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 4px;
      }
      
      .wa-console .dropdown-item {
        display: block;
        width: 100%;
        padding: 10px 16px;
        background: none;
        border: none;
        color: white;
        text-align: left;
        cursor: pointer;
        font-size: 12px;
        font-weight: 500;
        transition: all 0.2s ease;
        outline: none;
        display: flex;
        align-items: center;
        gap: 10px;
      }
      
      .wa-console .dropdown-item:hover {
        background: rgba(255,255,255,0.1);
        padding-left: 20px;
      }
      
      .wa-console .dropdown-item:active {
        background: rgba(255,255,255,0.2);
      }
      
      .wa-console .dropdown-item.active {
        background: rgba(102, 126, 234, 0.3);
        border-left: 3px solid #667eea;
      }
      
      .wa-console .dropdown-icon {
        width: 16px;
        height: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        opacity: 0.8;
      }
      
      @media (max-width: 768px) {
        .wa-console #debugger-container {
          height: 40px !important;
        }
        
        .wa-console #debugger-bar {
          padding: 2px 2px 2px 38px;
          height: 40px;
          overflow: hidden;
        }
        
        .wa-console .debugger-content {
          flex-direction: row;
          align-items: center;
          justify-content: space-between;
          gap: 5px;
          height: 100%;
          flex-wrap: nowrap;
        }
        
        .wa-console .debugger-section {
          display: flex;
          align-items: center;
          gap: 4px;
          min-width: 0;
          flex-shrink: 1;
        }
        
        .wa-console .debugger-section:first-child {
          flex: 1;
          min-width: 0;
          overflow: hidden;
        }
        
        .wa-console .debugger-section:last-child {
          flex-shrink: 0;
        }
        
        .wa-console .debugger-status {
          padding: 3px 8px;
          font-size: 9px;
          gap: 4px;
          flex-shrink: 0;
        }
        
        .wa-console .debugger-info {
          font-size: 9px;
          gap: 8px;
          overflow: hidden;
          flex: 1;
          min-width: 0;
        }
        
        .wa-console .debugger-info span {
          gap: 3px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          min-width: 0;
        }
        
        .wa-console #debugger-toggle {
          width: 30px;
          height: 30px;
          font-size: 8px;
          bottom: 5px;
          left: 2px;
        }
        
        .wa-console .debugger-btn {
          padding: 4px 8px;
          font-size: 9px;
        }
        
        .wa-console .console-modal-content {
          width: 95%;
          max-height: 90%;
        }
        
        .wa-console .console-modal-header {
          padding: 12px 15px;
        }
        
        .wa-console .console-modal-title {
          font-size: 14px;
        }
        
        .wa-console .console-modal-body {
          padding: 15px;
          max-height: 400px;
        }
        
        .wa-console .error-json, .stack-trace {
          font-size: 10px;
        }
        
        .wa-console .dropdown-menu {
          min-width: 160px;
          right: -5px;
        }
        
        .wa-console .dropdown-toggle {
          padding: 4px 8px;
          font-size: 9px;
          gap: 4px;
        }
        
        .wa-console .dropdown-item {
          padding: 6px 10px;
          font-size: 10px;
        }
        
       .wa-console  .dropdown-section-title {
          font-size: 9px;
        }
        
        .wa-console .routes-table th {
          padding: 8px 4px;
          font-size: 9px;
        }
        
        .wa-console .routes-table td {
          padding: 6px 4px;
          font-size: 9px;
        }
        
        .wa-console .method-badge {
          font-size: 8px;
          padding: 1px 4px;
        }
        
        .wa-console .type-badge {
          font-size: 8px;
          padding: 1px 4px;
        }
      }

      @media (max-width: 480px) {
        .wa-console #debugger-container {
          height: 40px !important;
        }
        
        .wa-console #debugger-bar {
          padding: 1px 1px 1px 32px;
        }
        
        .wa-console .debugger-content {
          gap: 3px;
        }
        
        .wa-console .debugger-section {
          gap: 2px;
        }
        
        .wa-console .debugger-status {
          padding: 2px 6px;
          font-size: 8px;
          gap: 2px;
        }
        
        .wa-console .debugger-info {
          font-size: 8px;
          gap: 4px;
        }
        
        .wa-console .debugger-info span {
          gap: 2px;
        }
        
        .wa-console #debugger-toggle {
          width: 28px;
          height: 28px;
          font-size: 7px;
        }
        
        .wa-console .dropdown-toggle {
          padding: 3px 6px;
          font-size: 8px;
          gap: 2px;
        }
        
        .wa-console .dropdown-menu {
          min-width: 140px;
        }
        
        .wa-console .dropdown-item {
          padding: 5px 8px;
          font-size: 9px;
        }
        
        .wa-console .status-indicator {
          width: 8px;
          height: 8px;
        }
      }

      .wa-console .log {
        color: white;
        border: 1px solid white;
        background: rgba(255,255,255,0.1);
        text-transform: italic;
        border-radius: 4px;
        padding: 2px 8px;
        word-break: none;
        overflow: hidden;
        white-space: nowrap;
        overflow: hidden;   /* optional: hides overflow */
        text-overflow: ellipsis;
      }

      .wa-console .log-error {
        border: 1px solid red;
        background: rgba(255,0,0,0.5);
      }

      .wa-console .log-warning {
        border: 1px solid orange;
        background: rgba(255,165,0,0.5);
      }

      .wa-console .log-info {
        border: 1px solid #2196F3;
        background: rgba(33,150,243,0.5);
      }

      .wa-console .log-debug {
        border: 1px solid green;
        background: rgba(0,255,0,0.5);
      }

      .wa-console .log-fatal {
        border: 1px solid red;
        background: rgba(255,0,0,0.5);
      }

      .wa-console .logo{
        width: 100%;
        height: 100%;
      }

      .wa-console #debug-breakpoints {
        max-width: 400px;
        white-space: nowrap;
        overflow: hidden;   /* optional: hides overflow */
        text-overflow: ellipsis;
      }
    `;
    document.head.appendChild(styleSheet);
  }
  
  createElements() {
    // Create main container
    this.mainContainer = document.createElement('div');
    this.mainContainer.className = 'wa-console';
    document.body.appendChild(this.mainContainer);

    this.container = document.createElement('div');
    this.container.id = 'debugger-container';
    this.container.className = 'wa-console';

    // Create debugger bar
    const debuggerBar = document.createElement('div');
    debuggerBar.id = 'debugger-bar';
    
    // Create content wrapper
    const content = document.createElement('div');
    content.className = 'debugger-content';
    
    // Create left section (status and info)
    const leftSection = document.createElement('div');
    leftSection.className = 'debugger-section';
    
    // Create status element
    this.statusElement = document.createElement('span');
    this.statusElement.className = 'debugger-status status-running';
    this.statusElement.id = 'debug-status';
    
    const statusIndicator = document.createElement('span');
    statusIndicator.className = 'status-indicator indicator-green';
    
    const statusText = document.createElement('span');
    statusText.textContent = 'RUNNING';
    
    this.statusElement.appendChild(statusIndicator);
    this.statusElement.appendChild(statusText);
    
    // Create info section
    const infoDiv = document.createElement('div');
    infoDiv.className = 'debugger-info';
    
    // Time info
    const timeSpan = document.createElement('span');
    timeSpan.innerHTML = '';
    this.timeElement = document.createElement('span');
    this.timeElement.id = 'debug-time';
    this.timeElement.textContent = '00:00:00';
    timeSpan.appendChild(this.timeElement);
    
    // Memory info
    const memorySpan = document.createElement('span');
    memorySpan.innerHTML = 'MEM: ';
    this.memoryElement = document.createElement('span');
    this.memoryElement.id = 'debug-memory';
    this.memoryElement.textContent = '0 MB';
    memorySpan.appendChild(this.memoryElement);
    
    // Breakpoints info
    const breakpointsSpan = document.createElement('span');
    breakpointsSpan.innerHTML = '#';
    this.breakpointsElement = document.createElement('span');
    this.breakpointsElement.id = 'debug-breakpoints';
    this.breakpointsElement.textContent = ``;
    breakpointsSpan.appendChild(this.breakpointsElement);
    
    infoDiv.appendChild(timeSpan);
    infoDiv.appendChild(memorySpan);
    infoDiv.appendChild(breakpointsSpan);
    
    leftSection.appendChild(this.statusElement);
    leftSection.appendChild(infoDiv);
    
    // Create right section (dropdown menu)
    const rightSection = document.createElement('div');
    rightSection.className = 'debugger-section';
    
    // Create dropdown container
    const dropdown = document.createElement('div');
    dropdown.className = 'debugger-dropdown';
    
    // Create dropdown toggle button
    this.dropdownToggle = document.createElement('button');
    this.dropdownToggle.className = 'dropdown-toggle';
    this.dropdownToggle.textContent = '';
    
    // Create dropdown menu
    this.dropdownMenu = document.createElement('div');
    this.dropdownMenu.className = 'dropdown-menu';
    
    // Control Actions Section
    const controlSection = document.createElement('div');
    controlSection.className = 'dropdown-section';
    
    const controlTitle = document.createElement('div');
    controlTitle.className = 'dropdown-section-title';
    controlTitle.textContent = 'Control';
    controlSection.appendChild(controlTitle);
    
    // this.playBtn = this.createDropdownItem('AA', 'Continue');
    // this.pauseBtn = this.createDropdownItem('||', 'Update Languages');
    // this.stepBtn = this.createDropdownItem('DD', 'Step');
    // this.stopBtn = this.createDropdownItem('BB', 'Stop');
    this.restartBtn = this.createDropdownItem('CC', 'Restart');
    
    // controlSection.appendChild(this.playBtn);
    // controlSection.appendChild(this.pauseBtn);
    // controlSection.appendChild(this.stepBtn);
    // controlSection.appendChild(this.stopBtn);
    controlSection.appendChild(this.restartBtn);
    
    // Panel Actions Section
    const panelSection = document.createElement('div');
    panelSection.className = 'dropdown-section';
    
    const panelTitle = document.createElement('div');
    panelTitle.className = 'dropdown-section-title';
    panelTitle.textContent = 'Panels';
    panelSection.appendChild(panelTitle);
    
    this.consoleBtn = this.createDropdownItem('[]', 'Console');
    this.routesBtn = this.createDropdownItem('./', 'Routes');
    this.variablesBtn = this.createDropdownItem('{}', 'Variables');
    this.reinitBtn = this.createDropdownItem('@', 'Reinit');
    // this.settingsBtn = this.createDropdownItem('A', 'Settings');
    
    panelSection.appendChild(this.consoleBtn);
    panelSection.appendChild(this.routesBtn);
    panelSection.appendChild(this.variablesBtn);
    panelSection.appendChild(this.reinitBtn);
    // panelSection.appendChild(this.settingsBtn);
    
    // Assemble dropdown
    this.dropdownMenu.appendChild(controlSection);
    this.dropdownMenu.appendChild(panelSection);
    dropdown.appendChild(this.dropdownToggle);
    dropdown.appendChild(this.dropdownMenu);
    rightSection.appendChild(dropdown);
    
    // Assemble everything
    content.appendChild(leftSection);
    content.appendChild(rightSection);
    debuggerBar.appendChild(content);
    this.container.appendChild(debuggerBar);
    
    // Create toggle button
    this.toggleBtn = document.createElement('button');
    this.toggleBtn.id = 'debugger-toggle';
    this.toggleBtn.innerHTML = `<img class="wa-console logo" src="data:image/svg+xml,%0A%3Csvg viewBox='0 0 100 75' width='50' height='50' xmlns='http://www.w3.org/2000/svg'%3E%3Cmask id='mask0_78_100113' style='mask-type:alpha' maskUnits='userSpaceOnUse' x='27' y='10' width='35' height='63'%3E%3Cpath fill-opacity='1' fill='%23696cff' d='M52.7842 10.916L33.1458 24.3542C27.7968 28.6272 26.0082 33.9103 27.7799 40.2035C28.0294 41.0277 28.7959 43.981 32.6275 46.7169C33.9332 47.6492 36.7844 48.9064 41.1812 50.4883L41.081 50.5552L31.7038 56.8097C27.5674 60.1313 26.893 64.3206 29.6805 69.3773C32.0874 72.4947 36.5668 73.3427 40.1251 71.9675C42.4973 71.0507 48.3707 67.1525 57.7452 60.2727C60.7991 56.7157 62.0527 52.8355 61.506 48.632C60.6666 43.5019 57.2919 39.7936 51.3819 37.5071L47.3571 35.7936L61.905 25.3834L52.7842 10.916Z' /%3E%3C/mask%3E%3Cg mask='url(%23mask0_78_100113)' style='transform-origin: 43.9199px 42.8277px;' transform='matrix(0, 1.289188981056, 1.289188981056, 0, -14.91399262363, -2.402027429533)'%3E%3Cpath fill='%23696cff' d='M 47.357 35.794 C 30.199 30.488 32.96 27.301 37.088 22.308 C 40.224 18.515 24.593 29.632 27.78 40.204 C 28.029 41.029 28.796 43.981 32.627 46.717 C 33.933 47.649 36.784 48.906 41.181 50.488 L 41.081 50.555 L 31.704 56.81 C 27.567 60.131 26.893 64.321 29.681 69.377 C 32.087 72.495 36.567 73.343 40.125 71.968 C 42.497 71.051 48.371 67.153 57.745 60.273 C 60.799 56.716 62.053 52.836 61.506 48.632 C 60.667 43.502 57.292 39.794 51.382 37.507 L 47.357 35.794 Z' /%3E%3C/g%3E%3Cpath fill-opacity='1' fill='%23696cff' d='M 47.357 35.794 C 30.199 30.488 32.96 27.301 37.088 22.308 C 40.224 18.515 24.593 29.632 27.78 40.204 C 28.029 41.029 28.796 43.981 32.627 46.717 C 33.933 47.649 36.784 48.906 41.181 50.488 L 41.081 50.555 L 31.704 56.81 C 27.567 60.131 26.893 64.321 29.681 69.377 C 32.087 72.495 36.567 73.343 40.125 71.968 C 42.497 71.051 48.371 67.153 57.745 60.273 C 60.799 56.716 62.053 52.836 61.506 48.632 C 60.667 43.502 57.292 39.794 51.382 37.507 L 47.357 35.794 Z' transform='matrix(0, -1.2891889810562136, -1.2891889810562136, 0, 126.09708414912294, 97.5655579229581)' /%3E%3C/svg%3E" alt="Toggle Debugger">`;
    
    // Append to body
    this.mainContainer.appendChild(this.container);
    this.mainContainer.appendChild(this.toggleBtn);
  }

  showLog(message, type) {
    this.breakpointsElement.textContent = this.logs.length + ') ' + message;
    this.breakpointsElement.className = 'log log-' + type;
    this.logs.push(message);
  }

  createButton(id, text) {
    const button = document.createElement('button');
    button.id = id;
    button.className = 'debugger-btn';
    button.textContent = text;
    return button;
  }
  
  createDropdownItem(icon, text) {
    const item = document.createElement('button');
    item.className = 'dropdown-item';
    
    const iconSpan = document.createElement('span');
    iconSpan.className = 'dropdown-icon';
    iconSpan.textContent = icon;
    
    const textSpan = document.createElement('span');
    textSpan.textContent = text;
    
    item.appendChild(iconSpan);
    item.appendChild(textSpan);
    
    return item;
  }
  
  bindEvents() {
    // Toggle button
    this.toggleBtn.addEventListener('click', () => this.toggle());
    
    // Dropdown toggle
    this.dropdownToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      this.toggleDropdown();
    });
    
    // Close dropdown when clicking outside
    document.addEventListener('click', (e) => {
      if (!this.dropdownMenu.contains(e.target) && !this.dropdownToggle.contains(e.target)) {
        this.closeDropdown();
      }
    });
    
    // Control buttons
    // this.playBtn.addEventListener('click', () => {
    //   this.continue();
    //   this.closeDropdown();
    // });
    // this.pauseBtn.addEventListener('click', () => {
    //   this.pause();
    //   this.closeDropdown();
    // });
    // this.stepBtn.addEventListener('click', () => {
    //   this.step();
    //   this.closeDropdown();
    // });
    // this.stopBtn.addEventListener('click', () => {
    //   this.stop();
    //   this.closeDropdown();
    // });
    this.restartBtn.addEventListener('click', () => {
      this.restart();
      this.closeDropdown();
    });
    
    // Panel buttons
    this.consoleBtn.addEventListener('click', () => {
      this.openConsole(this.logs.join('\\n'));
      this.togglePanel('console');
      this.closeDropdown();
    });

    this.routesBtn.addEventListener('click', () => {
      window.socketDebugger.send(JSON.stringify({ path: 'get_routes' }));
      this.togglePanel('routes');
      this.closeDropdown();
    });

    this.variablesBtn.addEventListener('click', () => {
      window.socketDebugger.send(JSON.stringify({ path: 'get_data' }));
      this.togglePanel('variables');
      this.closeDropdown();
    });
    this.reinitBtn.addEventListener('click', () => {
      window.socketDebugger.send(JSON.stringify({ path: 'reinit' }));
      this.closeDropdown();
    });
    // this.settingsBtn.addEventListener('click', () => {
    //   this.togglePanel('settings');
    //   this.closeDropdown();
    // });
  }
  
  toggle() {
    this.isCollapsed = !this.isCollapsed;
    this.container.classList.toggle('collapsed', this.isCollapsed);
  }
  
  toggleDropdown() {
    const isOpen = this.dropdownMenu.classList.contains('show');
    if (isOpen) {
      this.closeDropdown();
    } else {
      this.openDropdown();
    }
  }
  
  openDropdown() {
    this.dropdownMenu.classList.add('show');
    this.dropdownToggle.classList.add('active');
  }
  
  closeDropdown() {
    this.dropdownMenu.classList.remove('show');
    this.dropdownToggle.classList.remove('active');
  }
  
  continue() {
    this.isRunning = true;
    this.updateStatus('running', 'RUNNING');
    this.setActiveButton(this.playBtn);
  }
  
  pause() {
    window.socketDebugger.send(JSON.stringify({ path: 'update_languages' }));
    this.setActiveButton(this.pauseBtn);
  }
  
  step() {
    this.simulateBreakpoint();
  }
  
  stop() {
    this.isRunning = false;
    this.updateStatus('stopped', 'STOPPED');
    this.setActiveButton(this.stopBtn);
    this.showNotification('Debugger stopped', 'error');
  }
  
  restart() {
    this.isRunning = true;
    this.startTime = Date.now();
    this.updateStatus('running', 'RESTARTING...');
    socketDebugger.send(JSON.stringify({ path: 'restart' }));
    this.setActiveButton(this.playBtn);
  }
  
  togglePanel(panel) {
    // Remove active class from all panel buttons
    [this.consoleBtn, this.variablesBtn, this.reinitBtn, this.settingsBtn]
      .forEach(btn => btn.classList.remove('active'));
    
    // Add active class to clicked button
    const targetBtn = panel === 'console' ? this.consoleBtn :
                     panel === 'variables' ? this.variablesBtn :
                     panel === 'callstack' ? this.reinitBtn : this.settingsBtn;
    targetBtn.classList.add('active');
  }
  
  setActiveButton(activeBtn) {
    [this.playBtn, this.pauseBtn, this.stopBtn].forEach(btn => btn.classList.remove('active'));
    activeBtn.classList.add('active');
  }
  
  updateStatus(status, text) {
    this.statusElement.className = 'debugger-status status-' + status;
    
    const indicator = this.statusElement.querySelector('.status-indicator');
    const textSpan = this.statusElement.querySelector('span:last-child');
    
    indicator.className = 'status-indicator indicator-' + 
      (status === 'running' ? 'green' : status === 'paused' ? 'yellow' : 'red');
    textSpan.textContent = text;
  }

  setTimer(timestamp) {
      const date = new Date(timestamp).toLocaleString("en-US", { timeZone: "UTC" });
      this.timeElement.textContent = date;
  }
  
  padZero(num) {
    return num.toString().padStart(2, '0');
  }
  
  simulateBreakpoint() {
    this.breakpoints++;
    this.breakpointsElement.textContent = this.breakpoints.toString();
  }
  
  showNotification(message, type, time = 3000) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'debugger-notification notification-' + type;
    notification.textContent = message;
    
    this.mainContainer.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
      notification.style.transform = 'translateX(0)';
    }, 10);
    
    // Remove after 3 seconds
    setTimeout(() => {
      notification.style.transform = 'translateX(100%)';
      setTimeout(() => {
        if (notification.parentNode) {
          this.mainContainer.removeChild(notification);
        }
      }, 300);
    }, time);
  }
  
  openConsole(errorData) {
    // Remove existing modal if any
    const existingModal = document.querySelector('.console-modal');
    if (existingModal) {
      existingModal.remove();
    }
    
    // Create modal overlay
    const modal = document.createElement('div');
    modal.className = 'console-modal';
    
    // Create modal content
    const modalContent = document.createElement('div');
    modalContent.className = 'console-modal-content';
    
    // Create header
    const header = document.createElement('div');
    header.className = 'console-modal-header';
    
    const title = document.createElement('h3');
    title.className = 'console-modal-title';
    
    // Check if data is routes array
    const isRoutesData = Array.isArray(errorData) && errorData.length > 0 && errorData[0].hasOwnProperty('path');
    title.textContent = isRoutesData ? 'DEBUG CONSOLE - ROUTES TABLE' : 'DEBUG CONSOLE - ERROR DETAILS';
    
    const closeBtn = document.createElement('button');
    closeBtn.className = 'console-modal-close';
    closeBtn.innerHTML = 'X';
    closeBtn.addEventListener('click', () => this.closeConsole());
    
    header.appendChild(title);
    header.appendChild(closeBtn);
    
    // Create body
    const body = document.createElement('div');
    body.className = 'console-modal-body';
    
    if (isRoutesData) {
      // Create routes summary
      const summary = document.createElement('div');
      summary.className = 'routes-summary';
      
      const summaryTitle = document.createElement('div');
      summaryTitle.className = 'routes-summary-title';
      summaryTitle.textContent = 'Routes Summary';
      
      const summaryInfo = document.createElement('div');
      summaryInfo.textContent = 'Total Routes: ' + errorData.length + ' | API: ' + errorData.filter(function(r) { return r.type === 'API'; }).length + ' | WEB: ' + errorData.filter(function(r) { return r.type === 'WEB'; }).length;
      
      summary.appendChild(summaryTitle);
      summary.appendChild(summaryInfo);
      
      // Create routes table
      const table = document.createElement('table');
      table.className = 'routes-table';
      
      // Create table header
      const thead = document.createElement('thead');
      const headerRow = document.createElement('tr');

      const headers = ['#', 'Method', 'Path', 'Type', 'Auth', 'Controller', 'Hosts'];
      headers.forEach(headerText => {
        const th = document.createElement('th');
        th.textContent = headerText;
        headerRow.appendChild(th);
      });
      
      thead.appendChild(headerRow);
      table.appendChild(thead);
      
      // Create table body
      const tbody = document.createElement('tbody');
      
      errorData.forEach(route => {
        const row = document.createElement('tr');
        // #
        const indexCell = document.createElement('td');
        indexCell.textContent = route['#'] || '-';
        row.appendChild(indexCell);
        // Method
        const methodCell = document.createElement('td');
        const methodBadge = document.createElement('span');
        methodBadge.className = 'method-badge method-' + route.method.toLowerCase();
        methodBadge.textContent = route.method;
        methodCell.appendChild(methodBadge);
        row.appendChild(methodCell);
        
        // Path
        const pathCell = document.createElement('td');
        pathCell.textContent = route.path || route.fullPath || '-';
        row.appendChild(pathCell);
        
        // Type
        const typeCell = document.createElement('td');
        const typeBadge = document.createElement('span');
        typeBadge.className = 'type-badge';
        typeBadge.textContent = route.type || 'UNKNOWN';
        typeCell.appendChild(typeBadge);
        row.appendChild(typeCell);
        
        // Auth
        const authCell = document.createElement('td');
        const authIndicator = document.createElement('span');
        authIndicator.className = 'auth-indicator auth-' + route.hasAuth;
        authCell.appendChild(authIndicator);
        authCell.appendChild(document.createTextNode(route.hasAuth ? 'Yes' : 'No'));
        row.appendChild(authCell);
        
        // Controller
        const controllerCell = document.createElement('td');
        controllerCell.textContent = route.controller || route.index || '-';
        row.appendChild(controllerCell);
        
        // Hosts
        const hostsCell = document.createElement('td');
        hostsCell.textContent = Array.isArray(route.hosts) ? route.hosts.join(', ') : (route.hosts || '*');
        row.appendChild(hostsCell);
        
        tbody.appendChild(row);
      });
      
      table.appendChild(tbody);
      
      // Assemble routes view
      body.appendChild(summary);
      body.appendChild(table);
    } else {
      // Handle error data (existing logic)
      // Parse error data
      let parsedError;
      try {
        parsedError = typeof errorData === 'string' ? JSON.parse(errorData) : errorData;
      } catch (e) {
        parsedError = { message: errorData || 'Unknown error', raw: errorData };
      }
      
      // Create error summary
      const summary = document.createElement('div');
      summary.className = 'error-summary';
      
      const errorTitle = document.createElement('div');
      errorTitle.className = 'error-title';
      errorTitle.textContent = parsedError.error || parsedError.message || parsedError.type || 'Runtime Error';
      
      const errorMessage = document.createElement('div');
      errorMessage.className = 'error-message';
      errorMessage.textContent = parsedError.message || parsedError.description || 'An error occurred during execution';
      
      summary.appendChild(errorTitle);
      summary.appendChild(errorMessage);
      
      // Create tabs
      const tabs = document.createElement('div');
      tabs.className = 'error-tabs';
      
      const jsonTab = document.createElement('button');
      jsonTab.className = 'error-tab active';
      jsonTab.textContent = 'JSON Data';
      jsonTab.addEventListener('click', () => this.switchTab('json'));
      
      const stackTab = document.createElement('button');
      stackTab.className = 'error-tab';
      stackTab.textContent = 'Stack Trace';
      stackTab.addEventListener('click', () => this.switchTab('stack'));
      
      const detailsTab = document.createElement('button');
      detailsTab.className = 'error-tab';
      detailsTab.textContent = 'Details';
      detailsTab.addEventListener('click', () => this.switchTab('details'));
      
      tabs.appendChild(jsonTab);
      tabs.appendChild(stackTab);
      tabs.appendChild(detailsTab);
      
      // Create tab contents
      const jsonContent = document.createElement('div');
      jsonContent.className = 'tab-content active';
      jsonContent.id = 'json-tab';
      
      const jsonCode = document.createElement('pre');
      jsonCode.className = 'error-json';
      jsonCode.textContent = JSON.stringify(parsedError, null, 2);
      jsonContent.appendChild(jsonCode);
      
      const stackContent = document.createElement('div');
      stackContent.className = 'tab-content';
      stackContent.id = 'stack-tab';
      
      const stackTrace = document.createElement('pre');
      stackTrace.className = 'stack-trace';
      stackTrace.textContent = parsedError.stack || parsedError.trace || parsedError.stackTrace || 'No stack trace available';
      stackContent.appendChild(stackTrace);
      
      const detailsContent = document.createElement('div');
      detailsContent.className = 'tab-content';
      detailsContent.id = 'details-tab';
      
      const detailsInfo = document.createElement('div');
      detailsInfo.innerHTML = 
        '<div class="error-section">' +
          '<div class="error-section-title">Error Type</div>' +
          '<div>' + (parsedError.type || parsedError.error || 'Unknown') + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">File</div>' +
          '<div>' + (parsedError.file || parsedError.filename || 'Unknown') + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">Line</div>' +
          '<div>' + (parsedError.line || parsedError.lineNumber || 'Unknown') + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">Timestamp</div>' +
          '<div>' + new Date().toLocaleString() + '</div>' +
        '</div>' +
        '<div class="error-section">' +
          '<div class="error-section-title">Session</div>' +
          '<div>' + (parsedError.session || 'Current Debug Session') + '</div>' +
        '</div>';
      detailsContent.appendChild(detailsInfo);
      
      // Assemble error view
      body.appendChild(summary);
      body.appendChild(tabs);
      body.appendChild(jsonContent);
      body.appendChild(stackContent);
      body.appendChild(detailsContent);
    }
    
    modalContent.appendChild(header);
    modalContent.appendChild(body);
    modal.appendChild(modalContent);
    
    // Add to DOM
    this.mainContainer.appendChild(modal);
    
    // Show modal with animation
    setTimeout(() => {
      modal.classList.add('active');
    }, 10);
    
    // Close on background click
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        this.closeConsole();
      }
    });
    
    // Close on Escape key
    const escapeHandler = (e) => {
      if (e.key === 'Escape') {
        this.closeConsole();
        document.removeEventListener('keydown', escapeHandler);
      }
    };
    document.addEventListener('keydown', escapeHandler);
  }
  
  closeConsole() {
    const modal = document.querySelector('.console-modal');
    if (modal) {
      modal.classList.remove('active');
      setTimeout(() => {
        if (modal.parentNode) {
          modal.remove();
        }
      }, 300);
    }
  }
  
  switchTab(tabName) {
    // Remove active class from all tabs and contents
    document.querySelectorAll('.error-tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    // Add active class to selected tab and content
    event.target.classList.add('active');
    document.getElementById(tabName + '-tab').classList.add('active');
  }
}


// Initialize debugger when DOM is ready
function initDebugger() {
  window.debugger = new DebuggerStatusBar();
}

// Initialize based on document state
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initDebugger);
} else {
  initDebugger();
}

// Global function to open console with error data
window.openConsole = function(errorData) {
  if (window.debugger) {
    window.debugger.openConsole(errorData);
  } else {
    console.error('Debugger not initialized yet');
  }
};

// Example usage:
// openConsole({
//   error: "Syntax Error",
//   message: "Unexpected token at line 45",
//   file: "app.js",
//   line: 45,
//   stack: "Error: Syntax Error\\n    at Parser.parse (app.js:45:10)\\n    at main (app.js:123:5)"
// });


var socketDebuggerEvents = {
    connected: function (data) {
      this.output({ data: 'Web Socket connected' });
      console.log('Web Socket connected');
      // Update debugger status to running when connected
      if (window.debugger) {
        window.debugger.updateStatus('running', 'RUNNING');
        window.debugger.container.classList.remove('disconnected');
      }
    },

    close: function (e) {
        this.output({ data: 'Web Socket closed' });
        console.log('Web Socket closed');
        // Update debugger status to stopped when disconnected
        if (window.debugger) {
          window.debugger.updateStatus('stopped', 'STOPPED');
          window.debugger.container.classList.add('disconnected');
          window.debugger.showNotification('WebSocket disconnected - Reconnecting in 3s...', 'error', 3000);

          // Try to reconnect after 3 seconds
          setTimeout(() => {
            window.debugger.showNotification('Attempting to reconnect...', 'warning');
            initWebSocketConnection();
          }, 3000);
        }
    },

    output: function (data) {
        if (typeof socketDebuggerOutput === 'undefined') {
          window.socketDebuggerOutput = 0;
        }
        window.socketDebuggerOutput++;
        console.log(data);
    },

    clients: function (data) {
        console.log('Web Socket clients:', data);
    },

    streamServer: function (data) {
        console.log('Web Socket clients:', data);
    },

    restartStarted: function (data) {
        window.debugger.showNotification('Debugger restarting...', 'error', 10000);
        setTimeout(() => {
          window.location.reload();
        }, 11000);
    },

    updateMemory: function (data) {
        window.debugger.memoryElement.textContent = `\${data.data.memory}  |  MAX: \${data.data.max_memory}`;
        window.debugger.setTimer(data.timestamp);
    },

    console: function (data) {
        window.debugger.openConsole(data.data.error);
    },

    update_languages: function (data) {
        window.debugger.showNotification('Language updated', 'info');
    },

    get_routes: function (data) {
      var routes = data.data.routes;
      window.debugger.openConsole(routes);
    },

    log: function (data) {
        window.debugger.showLog(data.data.message, data.data.type);
    }
}

var socketDebugger = null;
var socketDebuggerOutput = 0;

function initWebSocketConnection() {
  try {
    if (socketDebugger && socketDebugger.readyState === WebSocket.OPEN) {
      socketDebugger.close();
    }
    
    socketDebugger = new WebSocket("/debugger");
    
    socketDebugger.onopen = function(e) {
      socketDebuggerEvents.connected({ data: 'Connected' });
    };
    
    socketDebugger.onmessage = function (e) {
        var data = JSON.parse(e.data);
        
        if (socketDebuggerEvents[data.path]) {
            socketDebuggerEvents[data.path](data);
        }
    };

    socketDebugger.onclose = function (e) {
        socketDebuggerEvents.close(e);
    };
    
    socketDebugger.onerror = function (e) {
        console.error('WebSocket error:', e);
        if (window.debugger) {
          window.debugger.showNotification('WebSocket connection error', 'error');
        }
    };
  } catch (error) {
    console.error('Failed to create WebSocket connection:', error);
    if (window.debugger) {
      window.debugger.showNotification('Failed to connect to WebSocket', 'error');
    }
  }
}

// Initialize WebSocket connection
initWebSocketConnection();
""";

  @override
  Tag Function(Map args)? generateHtml;
}

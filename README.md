# 🤖 Auto-Paper-Explainer: Automated Paper Reading and Summarization Pipeline

[English](README.md) | [中文](README_ZH.md)

This is an automated academic paper processing workflow built on macOS Shortcuts and Google Gemini CLI.

It can achieve: **"Receive Inbox email subscription -> Auto-extract paper titles -> Scrape ArXiv PDF -> Call LLM for deep reading -> Generate local Markdown notes with architecture diagrams" fully automated closed-loop.**

Suitable for: **Those who want to quickly browse the latest papers every day, but find simple abstracts insufficient; have Inbox push but not enough time to read 4-5 papers daily; have Gemini Pro but find Claude Code API too expensive.**

## ✨ Core Features
* 📧 Email Auto-trigger: Uses macOS Shortcuts to automatically listen for emails with specific subjects (e.g., Scholar Alert Digest).

* 🕷️ Intelligent Information Scraping: Extracts paper titles via regex and uses Python scripts to automatically search arXiv and get direct PDF links.

* 🧠 Deep Structured Summarization: Based on a customized Gemini Prompt (Skill), it generates not just a TL;DR, but also deep analysis of model architecture, experimental conclusions, and even automatically draws network structure diagrams using Mermaid.js.

* 📂 Local Batch Processing: Besides email automation, independent Shell scripts are provided for batch parsing of local single PDFs or entire folders of PDFs.


## 🛠️ Prerequisites
Before running this workflow, please ensure your Mac has the following environment installed and configured:

* A macOS device capable of using the Shortcuts app.

* Python 3: requires `requests` and `beautifulsoup4` (for scraping arXiv links).
    ```bash
    pip install requests beautifulsoup4
    ```

* Gemini CLI: requires the official or third-party Gemini CLI tool to be installed and configured.
    ```bash
    brew install gemini-cli
    brew install poppler
    gemini
    ```

* [Scholar-Inbox](https://www.scholar-inbox.com/) registration, update preferences, and enable subscription emails.


## 🚀 Usage Guide
### 1. Clone Repository
```bash
git clone https://github.com/wz7in/auto-paper-reader.git
```

### 2. Configure Shortcuts
1. Open Shortcuts.app, create an automation, select "Receive Email" as the trigger, set filter conditions (e.g., subject contains "Scholar Alert Digest"), as shown below:

![](assets/1.png)

2. Add the following shortcut actions in the automation (remember to modify the paths in scripts):

![](assets/2.png)

### 3. Configure gemini-cli skill

```bash
mkdir -p ~/.gemini/skills/paper-explainer
mv SKILL.md ~/.gemini/skills/paper-explainer/
gemini
```

### 4. Modify Paths

Change paths in `bash_run.sh`, `bash_run_auto.sh`, and `get_arxiv_url.py` to your local paths.

### 5. Proxy

Turn on system proxy TUN mode.

### 6. Usage Methods

* Email Automation: When you receive a qualifying email, the Shortcut triggers automatically to complete the process from title extraction to note generation.

* Local Batch Processing: Run `bash_run_auto.sh` to batch process PDFs in a specified folder.
```bash
bash bash_run_auto.sh /path/to/your/pdf/folder
```
* Single File Processing: Run `bash_run.sh` with the PDF path to process a single file.
```bash
bash bash_run.sh /path/to/your/paper.pdf
```

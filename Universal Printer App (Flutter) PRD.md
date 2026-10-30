# Universal Printer App (Flutter) PRD

Oct 28, 2026 · @Parvez Hasan

A Flutter mobile app that finds, sets up and manages Bluetooth and Wi-Fi printers, then prints, scans and copies from the phone through a liquid glass interface.

### At a glance

| Item | Summary |
| --- | --- |
| Product | One printing, scanning and copying companion for Android and iOS, built with Flutter |
| Release 1 | Bluetooth and Wi-Fi printer setup, several saved printers, printing with the full settings set, printer scan and phone scan, basic copy |
| Printer coverage | Tiered: standards-based printers first (IPP, AirPrint, Mopria, eSCL), then raw, thermal and vendor modules |
| What sets it apart | One app for many brands; a UI driven by each printer's own capabilities; smart, on-device assistance; a liquid glass interface with a solid fallback |
| Privacy stance | Documents stay on the phone and the local network; AI features run on the device by default and are opt-in |
| Document status | Draft for review. Assumptions are in section 1, open questions in section 19, the phased plan in section 18 |

## 1. Product overview

**Vision.** One app that lets anyone set up a printer from their phone and then print, scan, copy and manage it, without installing a separate vendor app for each brand.

**Problem.** Every printer brand ships its own app. Setup is confusing, features differ, and many apps stop working on newer phones. People with more than one printer, such as home, office and a portable one, juggle several apps.

**Solution.** A single Flutter app with a universal printer layer that speaks the open printing and scanning standards (IPP, AirPrint/Mopria-style discovery, eSCL, raw port 9100), with vendor-specific drivers added where the standards fall short.

### Scope assumptions

Assumptions made while interpreting the brief. Confirm or correct each one before design starts.

| # | Your note | How this PRD reads it |
| --- | --- | --- |
| 1 | "Add printer: Bluetooth or Wi-Fi" | The Add Printer screen offers two setup paths: **Bluetooth setup** and **Wi-Fi setup**. |
| 2 | "Now it only add set up printer" | In Release 1 the Add Printer feature is the guided **Set up printer** flow only. Other ways to add (manual IP, USB-OTG, QR code, cloud) are listed and scheduled for later releases. |
| 3 | "Support all printers" | The app targets every printer that supports an open standard, plus a growing list of vendor protocols. No app can honestly guarantee 100% of printers, so section 4 lists exactly what is covered and what is not. |
| 4 | "All multifunction printer functions" | Print, scan, copy, fax, status, maintenance and supplies are in scope. Functions that need vendor cloud accounts or hardware access the phone lacks are marked Later or Not possible. |
| 5 | Liquid glass UI | Built with a Flutter liquid glass package (section 13), with a plain-material fallback for low-end devices. |

**Platforms:** Android and iOS in the first release. Tablets are supported with an adaptive layout.

**Release priority labels used in this document:** **P0** = must ship in Release 1, **P1** = Release 2, **P2** = Release 3 or later.

## 2. Goals, non-goals and success metrics

**Goals**

- A first-time user adds a printer and prints a test page in under 2 minutes.
- Print and scan from one app with the same settings the printer's own app offers.
- Manage several printers and switch between them in two taps.
- A polished, consistent liquid glass look on Android and iOS.

**Non-goals (Release 1)**

- Replacing OS-level drivers on desktop platforms (Windows, macOS, Linux).
- Large-format, 3D, label-design or industrial printing workflows.
- Building a cloud print service; the app talks to printers directly.
- Full print-server or fleet management for IT admins.

**Success metrics (proposed targets, to be confirmed with beta data)**

| Metric | Target | How measured |
| --- | --- | --- |
| Setup success rate (printer added on first try) | 85% or higher | Analytics funnel: start setup to test page printed |
| Time to first print | Under 2 minutes median | Timestamp from first launch to job completed |
| Print job success rate | 97% or higher | Job status completed vs. failed |
| Scan job success rate | 95% or higher | Scan completed vs. failed |
| Crash-free sessions | 99.5% or higher | Crash reporting |
| Day-30 retention | 25% or higher | Analytics cohort |
| Store rating | 4.4 or higher | App Store and Google Play |

## 3. Users and use cases

| Persona | Typical printer | What they need most |
| --- | --- | --- |
| Student | Shared home inkjet or a campus printer | Print PDFs and notes fast, scan homework pages into one PDF |
| Home user | All-in-one Wi-Fi inkjet | Photos, documents, copying a form, ink level at a glance |
| Small office or shop | Laser MFP plus a thermal receipt or label printer | Several printers, saved presets, scan to PDF, secure print |
| Traveler or field worker | Portable Bluetooth printer | Print from the phone with no router, small paper sizes |
| Parent or teacher | Any Wi-Fi printer | Print worksheets and photos, copy pages, simple UI |

**Core use cases**

1. Set up a printer by Bluetooth or Wi-Fi without reading a manual.
2. Print a document, photo, web page or clipboard text with full control over settings.
3. Scan a page or a stack of pages from the printer glass or feeder and share the result.
4. Use the phone as a copier: scan on the printer, print on the same printer.
5. Check ink, paper and errors, then fix a stuck job or clean the print head.
6. Keep several printers saved and choose the right one per job.

## 4. Platform and printer compatibility

"Works with all printers" is delivered in tiers. The app covers every printer that follows an open standard, then adds vendor and thermal protocols one by one. The compatibility list is shown to users inside the app.

### Printer support tiers

| Tier | Printer type | Protocol the app uses | Print | Scan | Release |
| --- | --- | --- | --- | --- | --- |
| A | Wi-Fi printers with AirPrint, Mopria or IPP Everywhere (most printers from 2015 on) | IPP / IPPS (port 631), mDNS discovery; eSCL for scanning | Full | Full | P0 |
| B | Network printers without IPP but with a page language (PCL, PostScript) | Raw socket (port 9100) or LPR (port 515) | Basic | No | P1 |
| C | Portable and thermal printers (receipt, label, photo, mini) | Bluetooth Classic SPP (Android), BLE (Android and iOS), ESC/POS, TSPL, ZPL, CPCL | Basic | No | P0 for BLE and SPP receipt/label, P1 for others |
| D | Brand-specific features (ink status detail, cleaning, borderless photo, fax) | Vendor drivers added as modules: HP, Canon, Epson, Brother, Samsung/Xerox, Ricoh, Kyocera and others | Extended | Extended | P2 |
| E | Not supported | Host-based GDI printers that need a Windows driver, printers with USB only and no network or Bluetooth | None | None | Listed as unsupported |

### What Bluetooth and Wi-Fi can and cannot do

| Topic | Android | iOS |
| --- | --- | --- |
| Bluetooth Classic (SPP/RFCOMM) for thermal and portable printers | Supported | Not available to third-party apps without Apple's MFi program; use BLE printers only |
| Bluetooth Low Energy (BLE) printing | Supported | Supported |
| Bluetooth used to help join Wi-Fi (BLE provisioning) | Supported where the printer exposes it | Supported where the printer exposes it |
| Find Wi-Fi printers | mDNS/Bonjour via network service discovery | Bonjour; needs the Local Network permission and declared service types |
| Join the printer's own Wi-Fi (Wi-Fi Direct / setup hotspot) | Programmatic join via Wi-Fi suggestion or network specifier | Programmatic join via hotspot configuration, with a system prompt |
| Permissions | Bluetooth scan and connect (Android 12+), nearby Wi-Fi devices (Android 13+), location on older versions | Bluetooth, Local Network |

**Important product consequence:** most home inkjet and laser printers do not accept documents over Bluetooth. For them, the Bluetooth setup path is used to find the printer and hand it Wi-Fi credentials, and printing then happens over Wi-Fi. Portable and thermal printers print over Bluetooth directly. The Add Printer screen explains this in one line so users do not expect Bluetooth printing from every printer.

### Document formats

The app asks each printer which formats it accepts (IPP attribute `document-format-supported`) and converts the job to the best match: PDF, PWG raster, URF (Apple raster), JPEG, or PCL/PostScript for raw printers. The conversion happens on the phone so unsupported printers still receive something they can render.

### Operating system targets

- Android 8.0 (API 26) and later.
- iOS 15 and later.
- Phones and tablets, portrait and landscape.

Protocol and permission details in this section reflect general knowledge of the printing standards and platform rules and were not checked against primary sources for this draft. The engineering team should verify them against current Android, iOS and standards documentation before committing to the tiers.

## 5. Printer management

The Add Printer screen opens from the first-launch welcome, from the Printers tab and from any print or scan screen that has no printer selected. Release 1 ships the guided **Set up printer** flow with two paths.

### 5.1 Set up printer: Bluetooth path (P0)

1. User taps **Set up printer**, then **Bluetooth**.
2. App checks Bluetooth is on and permissions are granted; if not, a glass sheet explains why and opens the right setting.
3. App scans for nearby printers and lists them with name, signal strength and an icon for the printer type. Scan runs for up to 30 seconds with a Rescan button.
4. User taps a printer. App connects and reads model, supported paper sizes and capabilities.
5. If the printer is a Bluetooth-print type (portable, thermal), setup finishes here.
6. If the printer is a Wi-Fi printer that supports Bluetooth setup, the app asks the user to choose a Wi-Fi network, enters the password, sends it to the printer and waits for the printer to join.
7. App prints a test page (optional, on by default), asks for a printer nickname, and saves the printer.

### 5.2 Set up printer: Wi-Fi path (P0)

1. User taps **Set up printer**, then **Wi-Fi**.
2. App searches the current network and lists printers found. If the printer is already on the network, user taps it and continues at step 5.
3. If none appears, the app offers **Printer is not on my network yet**. It shows the printer's model-specific instructions to start setup mode (for example, hold the Wi-Fi button) and lists the printer's setup hotspot when seen.
4. App joins the setup hotspot, sends the home Wi-Fi name and password, and returns the phone to the home network.
5. App reads printer capabilities, prints an optional test page, asks for a nickname and saves the printer.

If both paths fail, a **Help me fix this** screen offers a checklist: same Wi-Fi band (2.4 GHz vs 5 GHz), printer powered and not in sleep, router client isolation, permissions, and a link to manual IP entry (P1).

### 5.3 Other ways to add a printer (scheduled)

| Method | What it does | Release |
| --- | --- | --- |
| Manual IP or hostname | Enter address and port; app probes IPP, then raw port 9100 | P1 |
| QR code or NFC tap | Scan the code on the printer to prefill address or setup info | P1 |
| USB-OTG cable (Android) | Detect a USB printer and print or scan over USB | P2 |
| Wi-Fi Direct | Connect to a printer that offers a direct peer connection | P1 |
| Cloud and email print | Print through a printer's email address or manufacturer cloud | P2 |
| Share a saved printer | Send a printer profile to another device by link or QR | P2 |

### 5.4 Multiple printers (P0)

- Save any number of printers. The list shows nickname, model, connection type (Bluetooth or Wi-Fi), location label, and live status.
- Mark one printer as **Default**. Optionally set a different default for print, scan and copy.
- Switch printer from a glass chip at the top of Print, Scan and Copy screens.
- Rename, change icon and color, add a location label (Home, Office), reorder, forget and re-pair.
- Per-printer saved presets: paper size, color mode, quality and two-sided choice are remembered for each printer.
- Printers that are off or out of range show as Offline but stay saved. The app retries in the background when the user opens it.
- Auto-select: if the user prints while on a known network, the app suggests the printer used last on that network.

### 5.5 Printer details screen (P0)

Shows model, manufacturer, firmware version, IP or Bluetooth address, MAC address, serial number (when the printer reports it), connection type, supported paper sizes and trays, supported languages and formats, color and two-sided support, scanner presence, and a Test page button. P1 adds ink or toner levels, page counters and an option to open the printer's web page.

## 6. Print

### 6.1 Print sources

| Source | Details | Release |
| --- | --- | --- |
| Documents | PDF, Word (.doc, .docx), Excel (.xls, .xlsx), PowerPoint (.ppt, .pptx), TXT, RTF, CSV, ODT, HTML, Markdown. Office files are converted to PDF on device or through a conversion step; the app tells the user if a file cannot be converted. | PDF, TXT, images P0; Office P1 |
| Photos | Phone gallery, albums, camera capture, multiple selection, HEIC and JPEG, PNG, WebP, GIF (first frame), RAW preview | P0 |
| Files | Phone storage, Files app, Android document picker, share-sheet "Open with" and "Share to" from any app | P0 |
| Camera | Take a picture, crop and print directly; document edge detection | P0 |
| Web page | Enter a URL or share from the browser; print as page, article view or screenshot | P1 |
| Clipboard | Print copied text or image | P1 |
| Cloud storage | Google Drive, iCloud Drive, Dropbox, OneDrive | P1 |
| Email and attachments | Open attachments shared from mail apps | P1 |
| Contacts and calendar | Print a contact card, a calendar day, week or month | P2 |
| Templates | Ruled paper, graph paper, planners, checklists, invoices, ID card layout, passport photo sheet, calendar, coloring pages | P1 |
| Labels and receipts | Label and receipt layouts for thermal printers: text, QR code, barcode, logo | P1 |
| Scanned items | Anything saved in the app's own Scan library | P0 |
| Recent and favorites | Re-print anything printed or scanned in the last 90 days, with the same settings | P0 |

### 6.2 Print flow (P0)

1. User picks a source and one or more items.
2. **Preview screen** opens with a large page preview, page thumbnails strip, page count and the printer chip at the top.
3. User adjusts settings in a glass bottom sheet (section 7). The preview updates live for color mode, orientation, scale and margins.
4. User taps **Print**. App converts, sends and shows a progress card with Cancel.
5. On finish the app shows a success state; on failure it shows the reason and a Retry button (see section 10 for the job queue).

### 6.3 Preview and edit before print

- Zoom and pan the page, swipe between pages, select pages by tapping thumbnails.
- Page range: all, current, custom (for example 1-3, 5, 8-10), odd only, even only.
- Rotate, crop, reorder, delete and duplicate pages (P1).
- Photo edit: crop to a paper ratio, rotate, brightness, contrast, filters, red-eye, auto-enhance (P1).
- Add header, footer, page numbers, date and a watermark (P2).
- Merge several files into one print job (P1).
- Password-protected PDFs: prompt for the password (P0).

### 6.4 Special print modes

| Mode | Description | Release |
| --- | --- | --- |
| Photo print | Photo paper sizes (4x6, 5x7, 8x10, A6), borderless, one photo per page or several, passport and ID layouts | P0 |
| Collage and contact sheet | Grid layouts of 2, 4, 6, 9 photos per page | P1 |
| Poster | Split one image over several pages with tiling marks | P2 |
| Booklet | Reorder pages for folding and two-sided printing | P2 |
| Envelope and label sheets | Common envelope sizes and label sheet templates | P2 |
| Test and alignment page | Nozzle check, alignment, color test | P0 test page, P1 others |
| Secure and PIN print | Job held at the printer until the user enters a PIN, where the printer supports it | P2 |
| Share-sheet printing | App appears as a print target from other apps | P0 |

## 7. Print settings

Settings open in a glass bottom sheet over the preview. The app only shows an option when the selected printer reports that it supports it; unsupported options are hidden or shown disabled with a reason. For Tier A printers each setting maps to the standard IPP attribute shown in the last column but one. All settings can be saved as a preset.

### 7.1 Basic

| Setting | Options | IPP attribute | Release |
| --- | --- | --- | --- |
| Printer | Chip showing the selected printer; tap to switch | n/a | P0 |
| Copies | 1 to 99 with stepper and keyboard entry | `copies` | P0 |
| Collate | On (1-2-3, 1-2-3) or off (1-1, 2-2, 3-3) | `multiple-document-handling` / `sheet-collate` | P0 |
| Pages | All, current page, custom range (1-3, 5, 8-10), odd pages only, even pages only, selected thumbnails | `page-ranges` | P0 |
| Orientation | Auto, portrait, landscape | `orientation-requested` | P0 |
| Reverse page order | On or off | `page-order-received` | P1 |
| Mirror image | On or off (iron-on and transfer paper) | app-side | P2 |

### 7.2 Color and quality

| Setting | Options | IPP attribute | Release |
| --- | --- | --- | --- |
| Color mode | **Color**, **Black and white** (black ink only), **Grayscale** (shades of gray); Auto where supported | `print-color-mode` (color, monochrome, auto, bi-level) | P0 |
| Print quality | Draft, Normal, High or Best, Photo | `print-quality` | P0 |
| Resolution | Printer-reported list, for example 300, 600, 1200 dpi | `printer-resolution` | P1 |
| Ink or toner saver | On or off; lighter output to save supplies | `print-content-optimize`, vendor option | P1 |
| Content type | Auto, text, graphics, photo, text and graphics | `print-content-optimize` | P1 |
| Image adjustments | Brightness, contrast, saturation, sharpness, color balance | app-side or vendor | P1 |
| Print speed | Normal or fast | vendor option | P2 |

Grayscale handling: the app converts the page to gray values on the phone, then sends it as monochrome when the printer supports it, or as color with gray values otherwise.

### 7.3 Paper

| Setting | Options | IPP attribute | Release |
| --- | --- | --- | --- |
| Paper size | A3, A4, A5, A6, B4, B5, Letter, Legal, Tabloid, Executive, Statement, Folio; photo sizes 3.5x5, 4x6, 5x7, 8x10, 10x15 cm; envelopes (No. 10, DL, C5, C6); custom width and height in mm or inches; roll widths for label printers | `media` | P0 |
| Paper type | Plain, recycled, thick or cardstock, photo glossy, photo matte, premium photo, brochure, labels, envelope, transparency, other | `media-type` | P0 |
| Paper source | Auto, tray 1, tray 2, tray 3, rear tray, manual feed or bypass, photo tray, roll | `media-source` | P0 |
| Paper size mismatch | Warn when the loaded paper does not match the job and offer to reprint on the loaded size | printer state reasons | P1 |
| Output tray | Auto, face up, face down, specific bin, mailbox | `output-bin` | P2 |

### 7.4 Layout, scaling and print area

| Setting | Options | IPP attribute | Release |
| --- | --- | --- | --- |
| Scale | **Fit to page** (shrink or grow to the printable area), **Fit to paper** (screen-fit: fills the whole sheet, may crop), **Fill page**, **Actual size (100%)**, **Custom %** from 10 to 400 | `print-scaling` (auto, auto-fit, fill, fit, none) | P0 |
| Print area | **Printable area** (stays inside what the printer can reach), **Maximum area** (reaches closest to the edge), **Borderless** (photos; where the printer supports it), **Custom margins** (top, bottom, left, right) | `media-col` margins, `media-type` borderless variants | P0 |
| Alignment | Center, top left, top center and the other positions | app-side | P1 |
| Pages per sheet | 1, 2, 4, 6, 9, 16, with layout order (left to right, top to bottom, and so on) and optional page border | `number-up`, `page-delivery` | P1 |
| Margins and gutter | Preset (normal, narrow, wide) or custom; binding gutter for hole punching | `media-col` | P1 |
| Booklet | Print pages in folded-booklet order, with two-sided | app-side | P2 |
| Header and footer, page numbers, watermark | Text, date, file name, page number, image | app-side | P2 |

### 7.5 Two-sided (duplex) printing

A single **Print on both sides** switch turns on two-sided printing. When it is on, a binding choice appears:

| Choice | What it means | When to use | IPP value |
| --- | --- | --- | --- |
| Off | One-sided | Default | `one-sided` |
| **Long edge** | Pages flip like a book; the back side keeps the same top as the front | Portrait documents bound on the left or right | `two-sided-long-edge` |
| **Short edge** | Pages flip like a notepad or calendar; the back side is upside down relative to the front | Landscape documents or top-bound notepads | `two-sided-short-edge` |

Other duplex behavior:

- A small animation in the glass sheet shows how the pages will flip for the chosen edge.
- The app picks a sensible default: long edge for portrait pages, short edge for landscape pages.
- If the printer has no automatic duplex unit, the app offers **Manual two-sided**: it prints the odd pages, tells the user to put the stack back in the tray (with a picture of the correct direction), then prints the even pages in the right order. (P1)
- Binding offset and margin for hole punching can be set in the Layout section. (P2)

### 7.6 Output and finishing (printers with a finisher)

| Setting | Options | IPP attribute | Release |
| --- | --- | --- | --- |
| Staple | None, top left, top right, dual | `finishings` | P2 |
| Hole punch | None, 2 hole, 3 hole, 4 hole | `finishings` | P2 |
| Fold | None, half fold, letter fold | `finishings` | P2 |
| Offset or group | Offset each copy | `finishings` | P2 |

### 7.7 Job control

| Setting | Options | Release |
| --- | --- | --- |
| Job name | Defaults to the file name; editable | P0 |
| Priority | Low, normal, high | P2 |
| Hold or schedule | Print now, hold, print later at a chosen time | P2 |
| PIN or secure print | Job waits at the printer until a PIN is entered | P2 |
| Notifications | Notify when the job finishes or fails | P0 |
| Save as preset | Name and save the current settings; choose a default preset per printer | P1 |
| Restore defaults | One tap back to the printer's defaults | P0 |

### 7.8 Settings behavior rules

- Remember the last settings per printer and per source type (photo vs document).
- Photo prints start with Photo quality, Borderless and photo paper suggestions.
- Show an estimated page count, sheets of paper used and, where supported, an ink usage estimate before printing.
- Show a plain-language warning when a choice may fail, for example borderless on plain paper.

## 8. Scan

There are two scan modes. **Printer scan** uses the scanner inside the printer through the eSCL (AirScan) protocol for Tier A printers, with vendor modules added later. **Phone scan** uses the phone camera as a scanner, so the app is useful even with a printer that has no scanner. Both end in the same editor and the same Scan library.

### 8.1 Scan flow (P0)

1. User opens the Scan tab and picks **Printer scan** or **Phone scan**.
2. For Printer scan the app reads the scanner's abilities and shows only what it supports.
3. User chooses an item type and settings (below), then taps **Preview**. The scanner makes a fast low-resolution pass and the app shows the image.
4. User adjusts the scan area on the preview, then taps **Scan**. A progress card shows pages received.
5. The scan opens in the editor. User can **Add page** (scan another sheet, same settings), edit, then **Save** or **Share**.
6. With an automatic document feeder (ADF) the app scans every sheet in one run and stops when the feeder is empty.

### 8.2 Scan item (what is being scanned)

Picking an item type sets sensible defaults for resolution, color and file type. All defaults can be changed.

| Item | Defaults | Release |
| --- | --- | --- |
| Document | Black and white or grayscale, 300 dpi, PDF, auto-deskew | P0 |
| Photo | Color, 600 dpi, JPEG, no auto-crop of border | P0 |
| ID card or passport | Color, 300 dpi, both sides placed on one page | P1 |
| Business card | Color, 600 dpi, contact extraction through OCR | P2 |
| Receipt | Grayscale, 300 dpi, auto-crop to the long narrow shape | P1 |
| Book page | Color or grayscale, page-curl and spine shadow reduction | P2 |
| Whiteboard | Color, glare and background clean-up | P2 (Phone scan) |
| Film or negative | Color, 2400 dpi or higher, only on scanners with a transparency unit | P2 |
| Text to edit (OCR) | Grayscale, 300 dpi, searchable PDF or text | P1 |

### 8.3 Scan settings

| Setting | Options | Release |
| --- | --- | --- |
| Source | Glass (flatbed), automatic document feeder, camera (Phone scan) | P0 |
| Sides (feeder) | One-sided, two-sided long edge, two-sided short edge | P0 |
| Color mode | **Color**, **Grayscale**, **Black and white** | P0 |
| Resolution | 75, 100, 150, 200, 300, 400, 600, 1200, 2400 dpi (only values the scanner reports) | P0 |
| Scan area | **Auto-detect** the item, **Full scanner glass**, **Custom area** drawn by dragging handles on the preview, or a **preset size** | P0 |
| Preset sizes | A4, A5, A6, B5, Letter, Legal, 4x6, 5x7, 8x10, business card, ID card, receipt, custom width and height | P0 |
| Orientation | Auto, portrait, landscape; rotate 90, 180, 270 | P0 |
| Brightness and contrast | Sliders and auto | P1 |
| Sharpness, saturation, color balance | Sliders | P1 |
| Background removal | Whiten paper background, remove show-through | P1 |
| Descreen and dust removal | Reduce moire from printed images; reduce specks | P2 |
| Skip blank pages | On or off, with a sensitivity setting | P1 |
| Auto-crop and deskew | On or off | P0 |
| Multi-page | Single file with all pages, or one file per page | P0 |
| Scan quality | Fast, normal, best | P1 |
| Keep scanner settings | Remember per printer and per item type | P1 |

When the scanner reports a limit (for example a maximum of 600 dpi for the feeder), the app shows the limit next to the control instead of silently changing the value.

### 8.4 Output formats

| Format | Details | Release |
| --- | --- | --- |
| PDF | Single or multi-page, adjustable compression | P0 |
| JPEG | Quality slider | P0 |
| PNG | Lossless | P1 |
| TIFF | Single and multi-page | P2 |
| Searchable PDF | OCR text layer behind the image | P1 |
| Text, Word (.docx) | Text extracted by OCR; OCR languages downloadable | P1 |
| Password-protected PDF | User sets a password | P1 |

### 8.5 Edit after scanning

- Crop with four-corner handles and auto edge detection (P0).
- Rotate, flip, reorder pages by drag, delete and duplicate pages (P0).
- Filters: original, document, grayscale, black and white, photo, whiteboard (P0).
- Brightness, contrast, sharpness (P1).
- Annotate: draw, highlight, text box, shapes, sticker (P1).
- Add signature or initials from a saved library (P1).
- Erase or blur selected areas (P2).
- Merge scans and split a PDF into several files (P1).

### 8.6 Save, share and destinations

- Save to the in-app **Scan library** with folders, tags, favorites, search by name and by text found through OCR (P0).
- Share through the system share sheet, email, messaging apps (P0).
- Save to the phone gallery or Files (P0).
- Send to cloud storage: Google Drive, iCloud Drive, Dropbox, OneDrive (P1).
- Send straight to **Print** or **Copy** from the editor (P0).
- Automatic file names with a template: date, time, document type, counter (P1).
- Scan to a network folder or email address defined on the printer, where supported (P2).
- Scan QR codes and barcodes with the phone camera and offer to open, copy or save the result (P1).

### 8.7 Scan error handling

The app handles and explains: scanner busy, scanner cover open, paper jam in feeder, no paper in feeder, scanner lamp warming, connection lost mid-scan (resume by re-requesting the missed pages when the scanner allows), and scans that are too large (offer a lower resolution).

## 9. Copy, fax and other multifunction functions

A multifunction printer (MFP) can copy, scan, fax and more. The app exposes every function the connected printer reports and hides the rest.

### 9.1 Copy (P0 for basic, P1 for advanced)

The phone is the control panel. Tapping **Copy** scans on the printer and prints on the same printer in one job.

| Setting | Options | Release |
| --- | --- | --- |
| Copies | 1 to 99 | P0 |
| Color mode | Color, black and white, grayscale | P0 |
| Source | Glass or automatic document feeder | P0 |
| Paper size and type | Same lists as section 7.3 | P0 |
| Paper tray | Auto or a specific tray | P1 |
| Quality | Draft, normal, best; text, photo or mixed | P1 |
| Lighter and darker | Slider | P1 |
| Enlarge and reduce | Actual size, fit to page, custom 25 to 400 percent, preset ratios such as A4 to A5 | P1 |
| Two-sided | One to one-sided, one to two-sided, two to one-sided, two to two-sided; long edge or short edge | P1 |
| Collate | On or off | P1 |
| Pages per sheet | 1, 2, 4 | P2 |
| **ID card copy** | Place a card, the app copies both sides onto one page | P1 |
| Preview before print | Scan preview on the phone, crop, then print | P1 |
| Margin shift and border erase | Shift image, remove dark scanner edges | P2 |

### 9.2 Fax (P2)

Only shown when the printer reports fax capability or when the user adds a supported online fax service.

- Send a fax: pick a document, photo or scan; enter a number or choose a contact; cover page; resolution (standard, fine, photo); send now or later.
- Receive fax: view received faxes from the printer memory, forward, print, delete.
- Fax log, speed dial list, broadcast to several numbers, redial and error report.

### 9.3 Other functions

| Function | Description | Release |
| --- | --- | --- |
| Print from the printer's memory or USB | Browse files on a USB stick or memory card inserted in the printer, print and scan to it | P2 |
| Scan to email, folder or cloud from the printer panel | Configure the printer's own scan destinations | P2 |
| Wireless Direct and Wi-Fi settings | View and change the printer's network name, IP address, join another network | P1 |
| Printer web page | Open the printer's built-in web page inside the app | P1 |
| Printer panel mirror | Show a virtual copy of the printer's screen where the vendor allows it | P2 |
| Eco and sleep settings | Sleep timer, power off timer, quiet mode, duplex by default | P2 |
| Date, time, region and language | Set on the printer | P2 |
| Printer name and location | Set the name the printer shows on the network | P1 |
| Paper tray setup | Tell the printer which paper size and type is loaded in each tray | P1 |
| Firmware update | Show the current version, check for an update, install with progress | P2 |
| Factory reset and network reset | With confirmation and a warning | P2 |
| Voice and smart-assistant hooks | Print shortcuts through the phone's assistant | P2 |

All printer-changing actions require a confirmation. Anything that needs the printer's admin password asks for it and does not store it unless the user chooses to.

## 10. Printer maintenance, supplies and job queue

### 10.1 Printer status (P0 basic, P1 detail)

- Live state on every printer card: Ready, Printing, Scanning, Busy, Sleeping, Offline, Needs attention.
- Plain-language alerts mapped from the printer's reported reasons: out of paper, paper jam, cover open, low ink or toner, tray missing, door open, output tray full, wrong paper size.
- Each alert has a **How to fix** card with steps and, where possible, an illustration.
- Local notification when a long job finishes or when the printer needs attention while a job is running.

### 10.2 Supplies (P1)

| Feature | Description |
| --- | --- |
| Ink or toner levels | Bars per cartridge with color names and percent where the printer reports them |
| Low supply alert | Notification at 20 percent and at empty |
| Cartridge details | Model numbers and a Buy link to a retailer or manufacturer page |
| Paper level | Per tray, when reported |
| Maintenance kit and drum life | Remaining life where reported |
| Page counters | Total, color and black pages, scans, copies |
| Usage history | Pages per day, week and month with a chart (P2) |

### 10.3 Maintenance tools (P1 unless noted)

| Tool | What it does |
| --- | --- |
| Test page | Prints a simple page to confirm the connection (P0) |
| Nozzle check | Prints a pattern that shows blocked nozzles |
| Print head cleaning | Normal and deep clean, with a warning about ink use |
| Print head alignment | Prints an alignment page and walks the user through choices |
| Paper feed and roller cleaning | Starts the printer's cleaning cycle |
| Calibration | Color and scanner calibration where the printer supports it (P2) |
| Printer self-diagnostic report | Prints or reads the printer's own status report |

Tools shown depend on what the printer or its vendor module exposes.

### 10.4 Job queue and history (P0)

- **Queue** shows jobs from this app (and, where the printer reports them, jobs from other devices): name, printer, pages, status, time.
- Actions: cancel, pause, resume, retry, move to top, delete from history.
- Statuses: Preparing, Sending, Waiting at printer, Printing, Completed, Failed, Canceled.
- Failed job shows the reason and a Retry that keeps the same settings.
- **History** keeps printed, scanned and copied items for 90 days by default (user can change or clear it), with search, filters by printer and type, and one-tap re-print.
- Offline queue: if the printer is unreachable, the job is held and sent when the printer returns, with the user's confirmation (P1).
- Background printing: a large job keeps sending when the app is in the background; an ongoing notification shows progress (P0 on Android, best-effort on iOS).

## 11. App settings and general features

| Area | Features | Release |
| --- | --- | --- |
| Onboarding | Three-screen welcome, permission explanations before each system prompt, then straight to Set up printer | P0 |
| Appearance | Light, dark and system theme; accent color; glass intensity (Low, Medium, High); **Reduce effects** switch for older phones | P0 |
| Language | Follows the phone; manual choice of language; right-to-left layout support | P0 |
| Units | Millimeters or inches, Letter or A4 as the default paper size by region | P0 |
| Defaults | Default printer, default color mode, default paper, default two-sided choice, default scan format | P0 |
| Notifications | Job done, job failed, printer needs attention, low ink or toner, tips | P0 |
| Storage | Show space used by scans and history; clear cache; auto-delete after 30, 90 or 365 days or never | P1 |
| Privacy | No document content leaves the phone unless the user shares it; analytics opt-in; app lock with biometrics or PIN for the Scan library | P1 |
| Backup and sync | Back up saved printers, presets and scan library to the user's own cloud drive | P2 |
| Widgets and shortcuts | Home-screen quick actions: Scan, Copy, Print photo, Print clipboard; Android app shortcuts and iOS Shortcuts actions | P1 |
| System print integration | Appears as a print service in the Android print system and in the iOS share sheet, so other apps can print through it | P0 |
| Help center | Setup guides by brand, troubleshooting steps, supported printers list, contact support, send diagnostic log (with consent) | P0 |
| Feedback and rating | Prompt after a successful job, never during setup | P1 |
| About | Version, licenses, terms and privacy policy | P0 |
| Account (optional) | Sign-in only for sync and premium; the app works fully without an account | P2 |
| Premium | Optional subscription for advanced features such as unlimited scan OCR, cloud destinations and batch tools; core print, scan and copy stay free | P2 |
| Accessibility | Screen readers, large text, high contrast mode, reduce motion, haptics | P0 |

## 12. Smart and next-generation features

These features turn the app from a remote control into an assistant. None is required to print or scan; each can be switched off, and the app works fully without them. Model and OS availability varies by device, so each feature has a fallback and is confirmed in the R0 spike before it is scheduled.

### 12.1 Feature list

| Feature | What the user gets | How it works | Release |
| --- | --- | --- | --- |
| Smart settings | The app picks sensible settings for the file: photo quality and borderless for pictures, ink saver for drafts, long edge or short edge for page orientation | Rules first (file type, page size, printer capabilities), then a small on-device classifier for photo vs text | P1 |
| AI scan clean-up | Straighter, cleaner scans: automatic crop and deskew, shadow and glare removal, background whitening, sharper low-resolution pages | On-device image processing, with an "original" toggle to compare | Deskew P0, rest P1 |
| OCR and document understanding | Searchable PDF, copy text, turn tables into spreadsheet files, pull fields from receipts, add a business card to contacts, translate text in place | On-device text recognition; translation on device where available | P1 to P2 |
| Print Assistant | Type or speak a request such as "print pages 2 to 5 in grayscale on both sides, 2 copies"; the app fills the settings and shows them for confirmation | Command parser turns the sentence into the settings in section 7; the user always confirms before anything prints | P2 |
| Smart library | Automatic titles, folders and tags; search by meaning ("electricity bill from March") instead of file names | On-device indexing of OCR text | P2 |
| Proactive troubleshooting | When a printer goes offline or a job fails, the app checks the network, the printer state and recent errors, then gives step-by-step fixes | Diagnostic checks plus the printer's reported state reasons, then guided steps | P1 |
| Predictive supplies | "Black ink runs out in about 3 weeks" and a one-tap link to buy cartridges | Usage history plus reported levels | P2 |
| Live progress | Print and scan progress on the lock screen and in the status area, with Cancel | iOS Live Activities and Dynamic Island, Android ongoing progress notifications, where the OS supports them | P1 |
| Proximity prompts | Walk near a saved printer and the app offers **Print here** or **Scan here** | Bluetooth LE signal strength and known network detection; always opt-in | P2 |
| Voice and shortcuts | "Scan to PDF", "Print my last photo" through the phone assistant and the Shortcuts app | App Intents (iOS) and app actions (Android) | P2 |
| Camera-assisted setup | Point the camera at the printer label or QR code to fill in model and setup details; on-screen arrows show which button to hold | Text and code recognition from the camera; short model-specific overlays | P2 |
| Sensitive-content check | A warning before printing a document with IDs, bank numbers or similar on a shared printer, with an offer to use secure print | On-device pattern detection | P2 |
| Eco insights | Paper and ink saved by two-sided and saver settings, shown as a simple monthly summary | Counters from job history | P2 |
| Continuity | Start a job on the phone and finish on a tablet; share printer profiles with family or colleagues by link | Device-to-device handoff and signed profile links | P2 |

### 12.2 AI principles

1. **On device by default.** Documents are processed on the phone. Any cloud processing needs a clear opt-in for that job and names what is sent.
2. **No training on user content.** Documents, scans and prompts are never used to train models.
3. **User confirms.** The assistant proposes settings; it never prints, deletes or changes a printer on its own.
4. **Explainable.** Each suggestion shows why it was made and can be dismissed for good.
5. **Graceful fallback.** If a model is missing or the device is too slow, the feature hides and the manual controls remain.
6. **Measured.** Each AI feature has a quality target set in R0, for example OCR accuracy on a test set of scans and the share of assistant requests parsed correctly, and ships only after meeting it.
7. **Accessible.** Voice and text input are both supported, and assistant output works with screen readers.

## 13. UI/UX design: liquid glass

### 13.1 Design principles

1. **Glass for controls, solid for content.** Glass is used on the layer that floats above content: navigation bar, tab bar, toolbars, sheets, chips, dialogs and menus. Document previews, scan images and lists stay on solid surfaces so they remain sharp and readable.
2. **One main action per screen.** A large glass primary button (Print, Scan, Copy, Add printer) is always in the same thumb zone at the bottom.
3. **Show only what the printer can do.** Controls that the printer does not support are hidden or disabled with a reason.
4. **Settings in sheets, not new pages.** Print, scan and copy settings open in a resizable glass bottom sheet over a live preview.
5. **Plain words.** "Both sides, flip on long edge" with a small animation, not only "duplex, long-edge binding".
6. **Always recoverable.** Every error has a cause in plain words and one clear next step.

### 13.2 Liquid glass package choice

Candidates reviewed on pub.dev and GitHub (see Sources). Four are relevant:

| Package | What it offers | Note |
| --- | --- | --- |
| `liquid_glass_renderer` (from the Flutter Liquid Glass workspace) | Renders the liquid glass refraction effect as a widget layer | Rendering engine; components are built on top of it |
| `flutter_liquid_glass_plus` | Ready widgets: app bar, button group, chip, icon button, panel, slider, switch, card, search bar, form field, picker, dialog, menu, sheet, with a quality setting | Version 0.0.7 at the time of checking, so early; the quality setting suits our fallback needs |
| `g1455` | Glass surface, button group, text field, scroll edge effect, dialog, alert, sheet; designed to avoid a backdrop filter per surface for lower GPU cost | Requires Flutter 3.47 or later; its API is marked 0.x and still changing |
| `liquid_glass_effect` (imported as `liquid_glass_ui`) | Frosted glass background, card and theme helper | Simpler frosted look rather than refraction |

**Recommendation.** Run a one-week spike on `liquid_glass_renderer`, `flutter_liquid_glass_plus` and `g1455` using the Scan preview and the Print settings sheet, measured on one mid-range and one low-end Android phone and one iPhone. Pick the package that holds 60 fps there. Whatever is chosen, wrap it in our own design-system widgets (`AppGlassBar`, `AppGlassSheet`, `AppGlassButton`, and so on) so the package can be swapped without touching feature code. All packages are young, so pin exact versions.

### 13.3 Design tokens

Values are a proposed starting point for the design team, not final.

| Token | Light | Dark |
| --- | --- | --- |
| Background gradient | Soft blue-white to pale lavender | Deep navy to near black |
| Accent (primary) | #0A84FF | #4DA3FF |
| Success, warning, error | #34C759, #FF9F0A, #FF453A | same, slightly lighter |
| Glass tint | White at 18 to 28 percent opacity | White at 8 to 14 percent opacity |
| Glass blur | 18 to 30 logical px (Low, Medium, High intensity) | same |
| Glass edge highlight | 1 px white at 40 percent opacity | 1 px white at 22 percent opacity |
| Corner radius | Cards 24, sheets 32, buttons fully rounded, chips fully rounded | same |
| Spacing scale | 4, 8, 12, 16, 24, 32 | same |
| Type | System font (SF Pro on iOS, Roboto or Google Sans on Android); title 28, section 20, body 16, caption 13 | same |
| Minimum touch target | 48 by 48 dp | same |

### 13.4 Component library

| Component | Where it is used | Behavior |
| --- | --- | --- |
| Glass tab bar | Bottom navigation: Home, Print, Scan, Printers, Settings | Floating capsule; the selected item has a moving glass highlight; hides on scroll |
| Glass app bar | Screen titles and actions | Becomes more opaque as content scrolls under it |
| Primary glass button | Print, Scan, Copy, Add printer, Save | Large, accent tint, press sinks and glows |
| Glass chip | Printer picker, paper size, color mode, filters | Tap to open a menu or sheet |
| Segmented glass control | Color, Grayscale, B and W; One-sided, Long edge, Short edge | Sliding glass thumb |
| Glass switch and slider | Toggles, brightness, scan quality, scale | Knob turns into a clear drop while dragged |
| Glass bottom sheet | Print, scan and copy settings; printer actions | Three snap points: peek, half, full; drag handle |
| Glass dialog and alert | Confirmations, errors with a fix button | Appears with blur first and tint last |
| Glass menu | More actions on a printer or file | Grows out of the button that opened it |
| Glass card | Printer card, recent item, supply level | Subtle parallax tilt on press (optional) |
| Glass search bar | Library and file search | Expands on focus |
| Progress glass card | Job progress, scan progress | Fluid fill; cancel button |
| Toast and banner | Job done, printer offline | Slides in over the tab bar |

### 13.5 Motion

- Screen transitions 250 to 350 ms with ease-out; sheets use spring motion.
- Printer scanning in Add Printer uses a radar-style glass ripple that stops when printers are found.
- The two-sided picker shows a short page-flip animation for long edge and short edge.
- All motion respects the system Reduce Motion setting and falls back to simple fades.

### 13.6 Performance and fallback

Glass effects are costly on low-end GPUs. The app must:

- Limit live glass surfaces to 3 at once on a screen and avoid glass over scrolling video-like content.
- Detect low memory, low-end devices, battery saver and the system Reduce Transparency setting, and switch to a **solid frosted fallback** (flat tinted surface with a border) automatically.
- Offer a manual **Reduce effects** switch in Settings.
- Hold 60 fps scrolling on the reference mid-range Android device; below 45 fps in testing means the fallback becomes the default for that device class.

### 13.7 Accessibility

- Text on glass meets 4.5 to 1 contrast against the worst-case background; if not, the glass becomes more opaque.
- Every control has a screen-reader label; the page preview has a text description of page count and size.
- Works at 200 percent text scale; no information is carried by color alone (ink levels also show a percent).
- Haptic feedback on key actions, switchable.

### 13.8 Adaptive and ambient experiences

These details give the app its modern, spatial feel. Each one follows the performance and accessibility rules above and drops to a simpler version when effects are reduced.

- **Adaptive glass.** Glass tint and contrast adjust to the content behind it, so a bright photo and a dark document both keep readable controls (P1).
- **Depth and light.** Cards and sheets respond to touch with a soft highlight; an optional subtle tilt effect uses the motion sensor (P2).
- **Command bar.** A glass bar at the bottom of Home accepts typed or spoken requests (see Print Assistant in section 12) and shows quick actions such as Print last photo, Scan, Copy (P1 quick actions, P2 language input).
- **Gesture-first preview.** Pinch to scale the print, rotate with two fingers, swipe up on the preview to print, swipe down to open settings; every gesture has a visible button alternative (P1).
- **Live surfaces.** Print and scan progress on the lock screen and status area, plus home-screen widgets for the default printer's status and supplies (P1).
- **Haptic language.** Distinct, light haptics for connected, printing started, finished and error, switchable in Settings (P1).
- **Fluid setup.** The Add Printer radar, connection progress and success states flow as one continuous animation instead of separate pages (P0 basic, P1 polish).
- **Adaptive layouts.** Phones, tablets and foldables get their own layouts: a two-pane preview and settings view on wide screens, one-handed reach zones on tall phones (P1).
- **Dark and OLED themes.** True dark surfaces with glass edges tuned for low light (P0).

## 14. Key screens

Bottom glass tab bar with five tabs: **Home**, **Print**, **Scan**, **Printers**, **Settings**. Copy sits on Home and inside Scan as a prominent action.

| # | Screen | Layout, top to bottom | Main actions | Empty and error states |
| --- | --- | --- | --- | --- |
| 1 | Welcome | Soft animated glass background, app name, three swipe cards (print, scan, manage), Get started | Get started, Skip | None |
| 2 | Home | Glass printer chip (selected printer and status), grid of four large action cards (Print document, Print photo, Scan, Copy), Recent items row, Supplies strip | Pick printer, start action, open recent | No printer: big **Set up printer** card replaces the grid |
| 3 | Add printer | Title, two large glass cards: **Bluetooth** and **Wi-Fi**, one-line explainer under each, "Need help?" link | Choose a path | Permission needed sheet; Bluetooth off sheet |
| 4 | Bluetooth scan | Radar ripple animation, list of found printers (name, signal, type), Rescan | Tap a printer to connect | Nothing found after 30 s: Help me fix this |
| 5 | Wi-Fi setup | Found printers on the network, then if needed the join-network form (network list, password field, show password) with progress steps | Select printer, enter Wi-Fi, Continue | Wrong password, printer not responding, 5 GHz network warning |
| 6 | Setup success | Printer image or icon, name field, test page toggle, Default printer toggle, Done | Name, test page, Done | Test page failed: Retry or Skip |
| 7 | Printers | List of printer cards with status dot, connection icon, default badge; Add printer button | Open, set default, forget | Empty: illustration and Set up printer |
| 8 | Printer details | Hero card (name, model, status), Quick actions (Test page, Clean, Align), Supplies, Capabilities, Network info, Presets, Forget printer | Rename, maintenance, forget | Offline banner with Reconnect |
| 9 | Print home | Source tiles: Documents, Photos, Files, Camera, Web page, Clipboard, Cloud, Templates; Recent and Favorites | Choose a source | Permission needed sheet |
| 10 | Print preview | Printer chip on top, large page preview, page thumbnail strip, Print button, Settings handle | Page select, open settings, Print | Unsupported file: explain and offer conversion |
| 11 | Print settings sheet | Sections with segmented controls: Copies, Pages, Color, Paper, Layout, Both sides, Quality, More options; Save preset, Reset | Change settings, save preset | Options hidden when unsupported |
| 12 | Print progress | Glass card with progress, current page, Cancel, Run in background | Cancel | Failed card with reason and Retry |
| 13 | Scan home | Segmented control Printer scan or Phone scan, item type chips, settings summary line, big Scan button | Pick item, open settings, Preview, Scan | Printer has no scanner: switch to Phone scan |
| 14 | Scan preview and area | Scanned preview with draggable glass crop handles, preset size chips (A4, Letter, ID and so on), Auto-detect toggle, Rescan, Scan | Set area, choose size, Scan | Scanner busy or cover open banner |
| 15 | Scan editor | Page strip, large page view, bottom toolbar (Crop, Rotate, Filter, Adjust, Sign, Text), Add page, Save | Edit, add page, save, share | Unsaved changes dialog |
| 16 | Save and share | Name field, format and quality chips, destination chips (Library, Files, Share, Cloud) | Save, share, OCR | Storage full alert |
| 17 | Library | Search bar, folder chips, grid or list of scans and prints, multi-select | Open, rename, merge, share, delete | Empty: Scan something |
| 18 | Copy | Source chips, copies stepper, color mode, size and scale, both-sides control, big Copy button | Copy, preview | Printer has no scanner message |
| 19 | Queue and history | Segmented control Queue or History, job rows with status and actions | Cancel, retry, re-print | Empty: No jobs yet |
| 20 | Settings | Grouped list: Printers, Defaults, Appearance, Notifications, Storage, Privacy, Help, About | Change preferences | n/a |
| 21 | Help and troubleshooting | Search, popular issues, brand guides, Send diagnostic log | Open guide, contact support | n/a |

### Cross-screen rules

- The printer chip at the top of Print, Scan and Copy always shows which printer will be used and its status.
- Every long operation (setup, print, scan) offers Cancel and shows what the app is doing in words.
- Permission explanations appear in our own sheet before the system prompt, with a short reason.
- Tablet and landscape: the settings sheet becomes a right-side glass panel next to the preview.

## 15. Screen map

&#91;embedded content: screen map · 5 tabs, 19 screens\]

Copy and Queue open from Home, Library opens from Scan, and Add printer is also the first screen a new user sees after the welcome. The welcome and setup screens are described in section 14.

## 16. Technical architecture

&#91;embedded content: architecture · 5 layers, 5 driver types\]

Screens talk only to services and the printer repository. Each printer reports a capability model (paper sizes, color, two-sided, scanner and so on), and the UI shows only what that model allows. Drivers hide protocol differences, so adding a new brand means adding a driver, not changing screens. The tiers match section 4.

### Package candidates

Flutter has no single plugin that covers IPP printing, eSCL scanning, Bluetooth setup and every vendor protocol, so the app owns the protocol layer and uses packages for the pieces below. Status says how much I could confirm.

| Need | Candidate packages | Status |
| --- | --- | --- |
| Liquid glass UI | `liquid_glass_renderer`, `flutter_liquid_glass_plus`, `g1455` | Seen in search results on pub.dev and GitHub; benchmark in the R0 spike |
| IPP printing, mDNS discovery, raw TCP, IPP status | `nitro_printing` | Seen in search results; version 0.0.x, so treat as early |
| Thermal, Bluetooth and network printers (ESC/POS) | `thermal_printer_flutter`, `flutter_net_printer`, `smart_printer_flutter`, `flutter_printlink` | Seen in search results; check maintenance and iOS support before use |
| eSCL (AirScan) scanning | None identified (not searched for specifically) | Plan to write an eSCL client in Dart (HTTP and XML) unless the spike finds one |
| Creating PDFs and the OS print dialog | `printing`, `pdf` | From my knowledge, not checked in this session |
| Bluetooth LE | `flutter_blue_plus` | From my knowledge, not checked in this session |
| Permissions, notifications, sharing, file and image pickers | `permission_handler`, `flutter_local_notifications`, `share_plus`, `file_picker`, `image_picker` | From my knowledge, not checked in this session |
| PDF viewing, OCR, document edge detection | a PDF viewer plugin, an ML Kit text-recognition plugin, a document-scanner plugin | Category only; choose and verify during R1 |
| State, storage, secure storage | `riverpod` or `flutter_bloc`, `drift`, `flutter_secure_storage` | From my knowledge, not checked in this session |

Platform code (Kotlin and Swift) is expected for Wi-Fi joining, Bluetooth provisioning, background jobs and the system print service, behind Dart interfaces.

## 17. Non-functional requirements

| Area | Requirement |
| --- | --- |
| Startup | Cold start to Home in under 2 seconds on the mid-range reference phone |
| Discovery | Printers on the local network appear within 5 seconds; Bluetooth scan shows first result within 5 seconds |
| Print speed | Preview of a 20-page PDF in under 3 seconds; job sent within 5 seconds of tapping Print for documents under 10 MB |
| Scan speed | Preview scan displayed in under 10 seconds after the scanner returns data; 300 dpi A4 page saved in under 3 seconds after receipt |
| Memory | Handle 100-page PDFs and 20-page scans without crashing; pages decoded on demand and cached to disk |
| Reliability | Retry sending a failed network job up to 3 times with back-off; resume or clearly restart scans after a dropped connection |
| Security | Use IPPS (TLS) when the printer offers it and warn on plain IPP for sensitive jobs; accept self-signed printer certificates only after the user confirms the printer; store printer credentials in the platform secure storage (Keychain, Keystore) |
| Privacy | Documents and scans stay on the phone and the local network; no upload to our servers; analytics are opt-in, contain no document content or file names; diagnostic logs are sent only with user consent |
| App lock | Optional biometric or PIN lock for the Scan library and history |
| Permissions | Ask only when the feature is used; each prompt preceded by an in-app explanation. Bluetooth, Local Network (iOS), Nearby Wi-Fi devices (Android 13+), camera, photos, notifications |
| Compatibility | Android 8.0+, iOS 15+, phones and tablets; tested on at least 10 printer models in each of Tier A and Tier C before release |
| Localization | At least 15 languages at launch including right-to-left languages; all strings externalized; paper size and units follow region |
| Accessibility | WCAG 2.2 AA targets for contrast and touch size; full screen-reader support |
| Offline | Everything except cloud sources and help articles works with no internet, using only the local network or Bluetooth |
| Observability | Crash reporting, non-identifying counters for setup, print and scan funnels, per-protocol error codes |
| Quality | Unit tests for protocol layers with recorded printer responses; integration tests against printer simulators; a real-device printer lab; release gate of no open P0 bugs |
| Legal | Brand names are used only to describe compatibility; third-party licenses are listed in About; comply with store policies for Bluetooth, local network and background usage |

## 18. Release roadmap

Release 1 delivers the core brief: set up a printer by Bluetooth or Wi-Fi, keep several printers, print documents and photos with full settings, and scan. Everything else is staged after it.

&#91;embedded content: release roadmap · 4 phases, 4 gates\]

| Release | Theme | Scope | Exit gate |
| --- | --- | --- | --- |
| R0 (spike, 2 weeks) | Prove the risky parts | Liquid glass package benchmark; IPP print to 3 printers; eSCL scan from 2 printers; BLE connect to 1 thermal printer; iOS Local Network and Android Bluetooth permissions | Decision on glass package; protocol layer demo works on real printers |
| R1 (P0) | Set up, print, scan | Set up printer by Bluetooth and Wi-Fi; multiple printers; Tier A and Tier C printers; PDF, image and photo printing; all print settings marked P0 including two-sided; printer scan with color, area, size and resolution; phone scan; editor basics; library; queue and history; basic copy; share-sheet printing; onboarding, settings, help, accessibility | Setup success 85 percent or higher in beta; no open P0 bugs; passes the printer lab test list |
| R2 (P1) | Complete multifunction use | Office files, web page, cloud sources; manual IP, QR and NFC add; Wi-Fi Direct; Tier B raw printing; manual two-sided; presets; supplies levels; maintenance tools; OCR; ID card copy and scan; widgets and shortcuts; app lock; smart settings; AI scan clean-up; proactive troubleshooting; live progress on the lock screen | 4.4 store rating; job success 97 percent or higher |
| R3 (P2) | Pro and brand depth | Vendor modules for the top printer brands; fax; finishing; secure print; USB-OTG; backup and sync; premium subscription; poster, booklet, label and envelope tools; firmware update; Print Assistant; smart library; predictive supplies; proximity prompts; voice and shortcuts | Vendor module coverage of the brands that account for most users' printers |

Estimates for time per release depend on team size and are left for the engineering plan.

## 19. Risks, open questions and acceptance criteria

### Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| "All printers" cannot be guaranteed | Bad reviews if users expect every printer to work | Tiered support list in the app and store listing; compatibility report button; vendor modules over time |
| iOS cannot use Bluetooth Classic without Apple's MFi program | Some Bluetooth printers will not work on iPhone | Support BLE printers on iOS; show a clear message; evaluate MFi for later |
| Most home printers do not print over Bluetooth | Users may expect Bluetooth printing from them | Explain on the Add Printer screen; use Bluetooth for setup and then Wi-Fi |
| Printers return different or buggy IPP and eSCL answers | Wrong options or failed jobs | Capability-driven UI; per-model quirk table; printer lab; remote-updatable quirk list |
| Liquid glass packages are young and APIs change | Rework, jank on low-end phones | Wrapper design system; pinned versions; solid fallback; early benchmark spike |
| Local network, Bluetooth and background rules change in OS updates | Discovery or background printing breaks | Track OS betas; automated permission tests; keep the setup help screen current |
| Office file conversion is hard on device | Wrong layout when printing Word or Excel files | Phase it in R2; show a preview before printing; allow export to PDF first |
| No Flutter plugin covers every need (eSCL, BLE provisioning, vendor protocols) | Build effort higher than expected | Plan to write native or Dart protocol code ourselves; keep plugins behind interfaces |
| On-device AI quality and device support vary | Wrong suggestions, slow features on older phones, inconsistent results across devices | Quality targets set in R0; features hidden when the device is too slow; manual controls always available; user confirms every AI action |

### Open questions

- Should "Set up printer" in Release 1 also include manual IP entry, or only the two guided paths as in this document?
- Which printer brands matter most for the first vendor modules?
- Is a premium subscription wanted, or should the app be fully free or ad-free paid?
- Which languages must be supported at launch?
- Is a desktop (Windows, macOS) version in the long-term plan?
- Should the app also be offered as the system print service on Android, replacing the default?

### Acceptance criteria for Release 1

- [ ] A new user can add a Wi-Fi printer and print a test page in under 2 minutes on 8 of 10 lab printers.
- [ ] Bluetooth setup works on at least 3 Bluetooth-capable printer models, and a BLE thermal printer prints a test receipt on both Android and iOS.
- [ ] A user can save 3 or more printers, switch between them in two taps and set a default.
- [ ] A PDF, a photo and a text file print correctly with each P0 setting in section 7, including two-sided long edge and short edge.
- [ ] Settings the printer does not support are hidden or disabled with a reason.
- [ ] A flatbed scan and a feeder scan complete with chosen color mode, resolution, scan area and preset size, and save as PDF and JPEG.
- [ ] Phone scan with edge detection saves a multi-page PDF.
- [ ] Failed jobs show a plain-language reason and Retry works.
- [x] Liquid glass UI holds 60 fps on the mid-range reference phone, and the solid fallback activates automatically on the low-end reference phone.
- [ ] Screen reader can complete setup, print and scan.

## 20. Glossary

| Term | Meaning |
| --- | --- |
| IPP, IPPS | Internet Printing Protocol, and its encrypted version; the open standard for sending print jobs and reading printer capabilities and status |
| IPP Everywhere, AirPrint, Mopria | Standards and certification programs that let phones print to compatible printers without a vendor driver |
| eSCL (AirScan) | Open protocol for scanning from a network scanner to a phone or computer over HTTP |
| mDNS, Bonjour | Local network discovery used to find printers and scanners without typing an address |
| MFP | Multifunction printer: prints and also scans, copies and sometimes faxes |
| ADF | Automatic document feeder: the tray that feeds a stack of sheets into the scanner |
| Duplex, two-sided | Printing or scanning on both sides of the sheet |
| Long edge, short edge | The edge on which the sheet flips for two-sided output: long edge like a book, short edge like a notepad |
| BLE, SPP | Bluetooth Low Energy, and the Bluetooth Classic serial profile used by many portable and thermal printers |
| ESC/POS, TSPL, ZPL | Command languages used by receipt printers and label printers |
| PCL, PostScript | Page description languages understood by many laser printers |
| PWG raster, URF | Raster image formats that standards-based printers accept |
| Wi-Fi Direct | A direct phone-to-printer wireless link that does not need a router |
| OCR | Optical character recognition: turning an image of text into editable and searchable text |
| Capability model | The list of features a specific printer reports, which the app uses to decide which controls to show |
| Liquid glass | A translucent, refracting interface style for controls and navigation layers that floats above content |
| Preset | A named set of print or scan settings that can be reused |
| Tier (A to E) | The level of printer support defined in section 4 |

## 21. Sources

Package names and descriptions come from search results on 2026-10-28. I read the result excerpts and did not open the full pages, so versions and maintenance status must be rechecked before the team commits. Protocol and platform statements (IPP attributes, eSCL, Bluetooth and Local Network rules) come from my own knowledge and are flagged in the text.

- [Flutter Liquid Glass workspace (`liquid_glass_renderer`)](https://github.com/whynotmake-it/flutter_liquid_glass/wiki)
- [`flutter_liquid_glass_plus` on pub.dev](https://pub.dev/packages/flutter_liquid_glass_plus/install)
- [`g1455` documentation](https://pub.dev/documentation/g1455/0.1.3/)
- [`liquid_glass_effect` documentation](https://pub.dev/documentation/liquid_glass_effect/1.0.0)
- [`nitro_printing` documentation](https://pub.dev/documentation/nitro_printing/0.0.6/)
- [`thermal_printer_flutter` on pub.dev](https://pub.dev/packages/thermal_printer_flutter)
- [`flutter_net_printer` documentation](https://pub.dev/documentation/flutter_net_printer/latest)
- [`smart_printer_flutter` documentation](https://pub.dev/documentation/smart_printer_flutter/latest/)
- [`flutter_printlink` changelog](https://pub.dev/packages/flutter_printlink/changelog)

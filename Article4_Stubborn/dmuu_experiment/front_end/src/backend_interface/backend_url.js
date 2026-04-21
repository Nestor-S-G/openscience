export let BACKEND_URL = process.env.REACT_APP_BACKEND_DEV_URL;

if (process.env.NODE_ENV === "production")
    BACKEND_URL = process.env.REACT_APP_BACKEND_PROD_URL;

// Backend API endpoints
// Get about json
export const BACKEND_API_ABOUT = BACKEND_URL + "about";

// Get the experiment config
export const BACKEND_API_CONFIG = BACKEND_URL + "config";

// Get the list of all experiments
export const BACKEND_API_LIST = BACKEND_URL + "list";

// Get FAQ pdf filename
export const BACKEND_API_PDFNAME = BACKEND_URL + "pdfname";

// Fetch the FAQ pdf
export const BACKEND_API_FETCHPDF = BACKEND_URL + "fetchpdf";

// Upload the FAQ pdf
export const BACKEND_API_UPLOADPDF = BACKEND_URL + "uploadpdf";

// Send finish page data
export const BACKEND_API_SETFINISH = BACKEND_URL + "setFinish";

// Get in progress experiment
export const BACKEND_API_GETINPROG = BACKEND_URL + "getInProgress";

// Update in progress experiment
export const BACKEND_API_EXUPDATE = BACKEND_URL + "exUpdate";

// Get finish data
export const BACKEND_API_GETFIN = BACKEND_URL + "getFinish";

// Upload backend database
export const BACKEND_API_UPLOADDB = BACKEND_URL + "uploaddb";

// Download backend database
export const BACKEND_API_DOWNLOADDB = BACKEND_URL + "fetchdb";

// Fetch excel experiment
export const BACKEND_API_FETCHXLS = BACKEND_URL + "fetchxls";

// Zip excel experiments
export const BACKEND_API_ZIPXLS = BACKEND_URL + "api/zipxls";

// Zip all excel experiments
export const BACKEND_API_ZIPXLSALL = BACKEND_URL + "api/zipxls?all=1";

// Create questionnaire
export const BACKEND_API_QCREATE = BACKEND_URL + "qcreate";

// Download questionnaire
export const BACKEND_API_QGET = BACKEND_URL + "qget";

// Fetch data for email
export const BACKEND_API_EMAIL = BACKEND_URL + "emails";

// Reset email
export const BACKEND_API_EMAILRESET = BACKEND_URL + "emailReset";

// Delete experiment
export const BACKEND_API_DELETE = BACKEND_URL + "delete";

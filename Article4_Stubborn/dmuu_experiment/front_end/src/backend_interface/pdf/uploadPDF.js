// Upload pdf file using axios
import axios from "axios";
import { BACKEND_API_UPLOADPDF } from "../backend_url";

export function uploadPDF(file, hook) {
    const formData = new FormData();

    formData.append("file", file);
    axios
        .post(BACKEND_API_UPLOADPDF, formData)
        .then(() => {
            console.log("Successfully uploaded PDF");
            if (hook) hook();
        })
        .catch(() => console.log("Failed to upload PDF"));
}

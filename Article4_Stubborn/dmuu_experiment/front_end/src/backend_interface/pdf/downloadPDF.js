// Download pdf file using axios
import axios from "axios";
import { BACKEND_API_FETCHPDF } from "../backend_url";

export function downloadPDF() {
    axios
        .get(BACKEND_API_FETCHPDF, {
            responseType: "arraybuffer",
        })
        .then((request) => {
            const url = window.URL.createObjectURL(
                new Blob([request.data], {
                    type: "application/pdf",
                })
            );
            const link = document.createElement("a");
            link.href = url;
            link.setAttribute("download", "FAQs.pdf");
            document.body.appendChild(link);
            link.click();
            URL.revokeObjectURL(url);
        })
        .catch((err) => console.log(err));
}

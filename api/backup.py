"""
دانلود فایل از روتر میکروتیک از طریق FTP.

RouterOS API (پورت 8728) خودش امکان انتقال محتوای خام فایل رو نمی‌ده —
فقط می‌تونه دستور بدیم که یه فایل (بکاپ/اکسپورت) روی خود روتر ساخته بشه.
برای دانلود واقعی اون فایل، از سرویس FTP روتر (که به‌صورت پیش‌فرض روی
پورت 21 فعاله) استفاده می‌کنیم.

نکته‌ی مهم: سرویس FTP باید روی روتر فعال باشه:
    /ip service enable ftp
و یوزر/پسوردی که استفاده می‌کنیم باید به FTP دسترسی داشته باشه (معمولاً
همون یوزر admin که برای API استفاده می‌کنیم کافیه).
"""

import ftplib
import io


class FtpDownloadError(Exception):
    """خطای اختصاصی برای مشکلات دانلود فایل از طریق FTP."""


def download_file_via_ftp(
    host: str,
    username: str,
    password: str,
    remote_filename: str,
    port: int = 25,
    timeout: int = 20,
) -> bytes:
    """
    اتصال به سرویس FTP روتر و دانلود محتوای یک فایل مشخص.

    Args:
        host: آی‌پی یا هاست‌نیم روتر.
        username: یوزرنیم (همون یوزر API).
        password: پسورد.
        remote_filename: اسم دقیق فایل روی روتر (مثلاً "backup_20260801.backup").
        port: پورت FTP (پیش‌فرض میکروتیک: 21).
        timeout: حداکثر زمان انتظار برای اتصال/دانلود، به ثانیه.

    Returns:
        محتوای خام فایل به‌صورت bytes.

    Raises:
        FtpDownloadError: اگه اتصال FTP برقرار نشه یا فایل پیدا نشه.
    """
    buffer = io.BytesIO()
    ftp = ftplib.FTP()
    try:
        ftp.connect(host, port, timeout=timeout)
        ftp.login(username, password)
        ftp.retrbinary(f"RETR {remote_filename}", buffer.write)
    except (*ftplib.all_errors, OSError) as exc:
        raise FtpDownloadError(
            f"Could not download '{remote_filename}' from {host}:{port} via FTP: {exc}"
        ) from exc
    finally:
        try:
            ftp.quit()
        except Exception:
            try:
                ftp.close()
            except Exception:
                pass

    return buffer.getvalue()

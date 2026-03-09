import Link from "next/link";
import Image from "next/image";

export function Footer() {
  return (
    <footer className="border-t border-gray-100 bg-gray-50 py-12">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="flex flex-col items-center gap-6 sm:flex-row sm:justify-between">
          <div className="flex items-center gap-2">
            <Image
              src="/app_icon.png"
              alt="お金の貸し借り アイコン"
              width={32}
              height={32}
              className="rounded-xl"
            />
            <span className="font-bold text-gray-900">お金の貸し借り</span>
          </div>

          <nav className="flex items-center gap-6 text-sm text-gray-500">
            <Link href="/privacy" className="hover:text-gray-900 transition-colors">
              プライバシーポリシー
            </Link>
            <a
              href="https://play.google.com/store"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-gray-900 transition-colors"
            >
              Google Play
            </a>
          </nav>
        </div>

        <div className="mt-8 border-t border-gray-200 pt-6 text-center text-xs text-gray-400">
          <p>© {new Date().getFullYear()} お金の貸し借り. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}

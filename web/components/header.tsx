import Link from "next/link";
import Image from "next/image";

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-white/80 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6">
        <Link href="/" className="flex items-center gap-2">
          <Image
            src="/app_icon.png"
            alt="お金の貸し借り アイコン"
            width={36}
            height={36}
            className="rounded-xl"
          />
          <span className="text-lg font-black tracking-tight text-gray-900">
            お金の貸し借り
          </span>
        </Link>

        <nav className="flex items-center gap-6">
          <Link
            href="/privacy"
            className="text-sm text-gray-500 hover:text-gray-900 transition-colors"
          >
            プライバシーポリシー
          </Link>
          <a
            href="https://play.google.com/store"
            target="_blank"
            rel="noopener noreferrer"
            className="hidden sm:inline-flex items-center gap-1.5 rounded-full bg-primary px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-primary/90 transition-colors"
          >
            <svg
              className="h-4 w-4"
              viewBox="0 0 24 24"
              fill="currentColor"
              aria-hidden="true"
            >
              <path d="M3.18 23.76c.3.17.64.24.99.2l13.38-11.91-3.23-3.23L3.18 23.76zm16.4-13.38L16.9 8.72 13.5 12l3.4 3.4 2.68-1.55a1.5 1.5 0 000-2.58l.01.01zM2.01 1.27C1.7 1.59 1.5 2.07 1.5 2.7V21.3c0 .63.2 1.11.51 1.43l.08.08 9.68-9.68v-.22L2.09 1.19l-.08.08zm11.42 9.83L4.04 1.7l-.01-.01c.3-.18.64-.25.99-.2l13.38 11.91-3.23 3.23-1.74-1.53z" />
            </svg>
            ダウンロード
          </a>
        </nav>
      </div>
    </header>
  );
}

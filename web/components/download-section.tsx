import Image from "next/image";

export function DownloadSection() {
  return (
    <section className="py-20 sm:py-28 bg-white">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 text-center">
        <Image
          src="/splash_icon_square.png"
          alt="お金の貸し借り"
          width={160}
          height={160}
          className="mx-auto mb-8 w-28 h-28 sm:w-36 sm:h-36"
        />
        <h2 className="text-3xl font-black tracking-tight text-gray-900 sm:text-4xl">
          今すぐ無料で始めよう
        </h2>
        <p className="mt-4 text-gray-500 max-w-md mx-auto leading-relaxed">
          友達とのお金の貸し借りをもっとスマートに。
          今すぐダウンロードして使い始めてください。
        </p>

        <div className="mt-10 flex items-center justify-center">
          <a
            href="https://play.google.com/store"
            target="_blank"
            rel="noopener noreferrer"
            className="transition-transform hover:scale-105 active:scale-95 drop-shadow-md"
          >
            <Image
              src="https://play.google.com/intl/ja/badges/static/images/badges/ja_badge_web_generic.png"
              alt="Google Play で手に入れよう"
              width={240}
              height={71}
              className="h-[71px] w-auto"
              unoptimized
            />
          </a>
        </div>
      </div>
    </section>
  );
}

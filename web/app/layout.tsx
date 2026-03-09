import type { Metadata } from "next";
import { Noto_Sans_JP } from "next/font/google";
import "./globals.css";

const notoSansJP = Noto_Sans_JP({
  variable: "--font-sans",
  subsets: ["latin"],
  weight: ["400", "500", "700", "900"],
});

export const metadata: Metadata = {
  title: "お金の貸し借り — 友達との貸し借りをスマートに管理",
  description:
    "友人・家族との貸し借りをかんたんに記録・管理できるスマートフォンアプリ。いつ、誰に、いくら貸したか借りたかを一目で確認。期日通知機能付き。",
  keywords: ["貸し借り", "お金管理", "割り勘", "貸したお金", "借りたお金"],
  icons: {
    icon: "/app_icon.png",
    apple: "/app_icon.png",
  },
  openGraph: {
    title: "お金の貸し借り",
    description: "友達との貸し借りをスマートに管理するアプリ",
    type: "website",
    images: [{ url: "/app_icon.png" }],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body className={`${notoSansJP.variable} antialiased`}>{children}</body>
    </html>
  );
}

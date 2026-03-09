import type { Metadata } from "next";
import Link from "next/link";
import { Header } from "@/components/header";
import { Footer } from "@/components/footer";

export const metadata: Metadata = {
  title: "プライバシーポリシー | お金の貸し借り",
  description: "お金の貸し借りアプリのプライバシーポリシーです。",
};

const LAST_UPDATED = "2026年3月9日";
const APP_NAME = "お金の貸し借り";
const CONTACT_EMAIL = "keishi.irisa@gmail.com";

export default function PrivacyPage() {
  return (
    <div className="min-h-screen">
      <Header />
      <main className="bg-gray-50 py-16 sm:py-24">
        <div className="mx-auto max-w-3xl px-4 sm:px-6">
          {/* Breadcrumb */}
          <nav className="mb-8 flex items-center gap-2 text-sm text-gray-400">
            <Link href="/" className="hover:text-primary transition-colors">
              ホーム
            </Link>
            <span>/</span>
            <span className="text-gray-700">プライバシーポリシー</span>
          </nav>

          <div className="rounded-2xl bg-white px-8 py-10 sm:px-12 sm:py-14 shadow-sm ring-1 ring-gray-100">
            <h1 className="text-3xl font-black tracking-tight text-gray-900 sm:text-4xl">
              プライバシーポリシー
            </h1>
            <p className="mt-3 text-sm text-gray-400">最終更新日：{LAST_UPDATED}</p>

            <div className="mt-10 space-y-10 text-sm leading-7 text-gray-700">
              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">はじめに</h2>
                <p>
                  {APP_NAME}（以下「本アプリ」）を提供する入佐啓士（以下「当方」）は、
                  本アプリの利用者（以下「ユーザー」）のプライバシーを尊重し、
                  個人情報の保護に努めます。本プライバシーポリシーは、本アプリが収集する情報、
                  その利用目的、および管理方法について説明します。
                </p>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第1条（収集する情報）
                </h2>
                <p className="mb-3">
                  本アプリは、以下の情報を収集することがあります。
                </p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>
                    <strong>端末識別子（デバイスID）：</strong>
                    アカウント登録不要でサービスを提供するために、端末固有のIDを生成・使用します。
                    このIDはユーザーの個人を特定するものではありません。
                  </li>
                  <li>
                    <strong>入力データ：</strong>
                    ユーザーが本アプリに入力した貸し借りの記録（相手の名前、金額、メモ、期日など）は、
                    サービス提供のためにサーバーに保存されます。
                  </li>
                  <li>
                    <strong>FCMトークン：</strong>
                    プッシュ通知の配信のために、Firebase Cloud Messaging（FCM）のトークンを取得・保存します。
                  </li>
                  <li>
                    <strong>アクセスログ：</strong>
                    サーバーへのアクセス日時、使用されたAPIのパスなど、
                    サービスの安定的な運営のために必要なログを記録します。
                  </li>
                </ul>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第2条（情報の利用目的）
                </h2>
                <p className="mb-3">収集した情報は、以下の目的のためにのみ利用します。</p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>本アプリのサービスの提供・運営・改善</li>
                  <li>返済期日に関するプッシュ通知の送信</li>
                  <li>不正利用の防止およびセキュリティの確保</li>
                  <li>技術的な問題の調査・対応</li>
                </ul>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第3条（第三者への提供）
                </h2>
                <p className="mb-3">
                  当方は、以下の場合を除き、ユーザーの情報を第三者に提供しません。
                </p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>ユーザーご本人の同意がある場合</li>
                  <li>法令に基づく場合</li>
                  <li>人の生命、身体または財産の保護のために必要がある場合</li>
                </ul>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第4条（第三者サービスの利用）
                </h2>
                <p className="mb-3">
                  本アプリは、以下の第三者サービスを利用しており、
                  各サービスのプライバシーポリシーが適用されます。
                </p>
                <ul className="list-disc pl-5 space-y-2">
                  <li>
                    <strong>Google Firebase / FCM：</strong>
                    プッシュ通知の送受信に使用しています。
                    <a
                      href="https://policies.google.com/privacy"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="ml-1 text-primary underline hover:no-underline"
                    >
                      Googleプライバシーポリシー
                    </a>
                  </li>
                  <li>
                    <strong>Supabase：</strong>
                    データベースの管理に使用しています。
                    <a
                      href="https://supabase.com/privacy"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="ml-1 text-primary underline hover:no-underline"
                    >
                      Supabaseプライバシーポリシー
                    </a>
                  </li>
                  <li>
                    <strong>Google Cloud（GCP）：</strong>
                    サーバーの運用に使用しています。
                  </li>
                </ul>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第5条（データの保管と削除）
                </h2>
                <p>
                  ユーザーのデータは、本アプリの提供に必要な期間保管されます。
                  ユーザーはいつでも本アプリ内からデータを削除することができます。
                  アプリのアンインストール後もサーバー上のデータは保持される場合があります。
                  データの削除をご希望の場合は、下記お問い合わせ先までご連絡ください。
                </p>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第6条（セキュリティ）
                </h2>
                <p>
                  当方は、ユーザーの情報の安全管理のために、
                  技術的・組織的なセキュリティ対策を講じています。
                  ただし、インターネット上での完全な安全性を保証することはできません。
                </p>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第7条（未成年者の利用）
                </h2>
                <p>
                  本アプリは、13歳未満のお子様の利用を想定していません。
                  13歳未満の方が本アプリを利用する場合は、
                  保護者の同意を得た上でご利用ください
                </p>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第8条（プライバシーポリシーの変更）
                </h2>
                <p>
                  当方は、必要に応じて本プライバシーポリシーを変更することがあります。
                  変更後のプライバシーポリシーは、本ページに掲載した時点から効力を生じるものとします。
                  重要な変更がある場合は、アプリ内またはウェブサイトにてお知らせします。
                </p>
              </section>

              <section>
                <h2 className="text-base font-bold text-gray-900 mb-3">
                  第9条（お問い合わせ）
                </h2>
                <p>
                  本プライバシーポリシーに関するお問い合わせは、以下のメールアドレスまでご連絡ください。
                </p>
                <p className="mt-3">
                  <a
                    href={`mailto:${CONTACT_EMAIL}`}
                    className="text-primary underline hover:no-underline"
                  >
                    {CONTACT_EMAIL}
                  </a>
                </p>
              </section>
            </div>
          </div>

          <div className="mt-8 text-center">
            <Link
              href="/"
              className="inline-flex items-center gap-2 rounded-full bg-primary px-6 py-3 text-sm font-semibold text-white shadow-sm hover:bg-primary/90 transition-colors"
            >
              <svg
                className="h-4 w-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M10 19l-7-7m0 0l7-7m-7 7h18"
                />
              </svg>
              トップページに戻る
            </Link>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}

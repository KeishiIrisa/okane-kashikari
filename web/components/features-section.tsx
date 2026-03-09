const features = [
  {
    icon: "📋",
    title: "貸し借りを一覧管理",
    description:
      "誰にいくら貸したか、誰からいくら借りているかを一覧で確認。「貸しリスト」「借りリスト」をタブで切り替えるだけ。",
    color: "bg-blue-50",
    iconBg: "bg-blue-100",
  },
  {
    icon: "🔔",
    title: "期日通知でうっかり防止",
    description:
      "返済期日を設定しておけば、当日に自動でプッシュ通知。「あれ、もう返してもらったっけ？」という心配がなくなります。",
    color: "bg-orange-50",
    iconBg: "bg-orange-100",
  },
  {
    icon: "💬",
    title: "LINEでスマートに催促",
    description:
      "相手の名前・金額・内容を自動でメッセージに組み込み。ワンタッチでLINEに送信できるので、気まずい一言も自然に伝えられます。",
    color: "bg-green-50",
    iconBg: "bg-green-100",
  },
  {
    icon: "⚡",
    title: "登録不要・すぐ使える",
    description:
      "アカウント登録・ログイン不要。アプリを入れたらすぐに記録をスタート。端末IDだけで動くのでプライバシーも安心。",
    color: "bg-purple-50",
    iconBg: "bg-purple-100",
  },
];

export function FeaturesSection() {
  return (
    <section className="py-20 sm:py-28 bg-white">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="text-center mb-14">
          <p className="text-sm font-semibold uppercase tracking-widest text-primary mb-3">
            特徴
          </p>
          <h2 className="text-3xl font-black tracking-tight text-gray-900 sm:text-4xl">
            かんたん・シンプルな4つの特徴
          </h2>
          <p className="mt-4 text-gray-500 max-w-xl mx-auto">
            必要な機能だけを厳選。複雑な設定なしで、誰でもすぐに使い始めることができます。
          </p>
        </div>

        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-2">
          {features.map((feature) => (
            <div
              key={feature.title}
              className={`rounded-2xl ${feature.color} p-6 sm:p-8 transition-transform hover:-translate-y-1`}
            >
              <div className="flex flex-col sm:flex-row gap-6">
                {/* Text content */}
                <div className="flex-1">
                  <div
                    className={`mb-4 inline-flex h-12 w-12 items-center justify-center rounded-xl ${feature.iconBg} text-2xl`}
                  >
                    {feature.icon}
                  </div>
                  <h3 className="mb-2 text-base font-bold text-gray-900">
                    {feature.title}
                  </h3>
                  <p className="text-sm leading-relaxed text-gray-600">
                    {feature.description}
                  </p>
                </div>

                {/* Phone image placeholder */}
                <div className="flex-shrink-0 self-center">
                  <div className="w-[100px] h-[180px] rounded-2xl bg-white/70 border-2 border-dashed border-gray-300 flex flex-col items-center justify-center gap-2 text-gray-300">
                    <svg className="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                    </svg>
                    <span className="text-[10px] text-center leading-tight px-1">
                      スクリーン<br />ショット
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

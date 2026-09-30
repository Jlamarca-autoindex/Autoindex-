import { createClient } from '@/utils/supabase/server'
import { cookies } from 'next/headers'

export default async function Page() {
  const cookieStore = await cookies()
  const supabase = createClient(cookieStore)

  const { data: listings, error } = await supabase
    .from('listings')
    .select(
      `
      id,
      title,
      price,
      market_price,
      mileage,
      transmission,
      drivetrain,
      title_status,
      image_url,
      created_at,
      profiles (
        username,
        avatar_url
      )
    `
    )
    .eq('status', 'active')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Failed to load listings:', error.message)
  }

  return (
    <ul>
      {listings?.map((listing) => (
        <li key={listing.id}>
          <strong>{listing.title}</strong> — ${listing.price.toLocaleString()}
          {listing.mileage != null && <> · {listing.mileage.toLocaleString()} mi</>}
          {listing.transmission && <> · {listing.transmission}</>}
          {listing.drivetrain && <> · {listing.drivetrain.toUpperCase()}</>}
          {listing.profiles?.username && <> · listed by {listing.profiles.username}</>}
        </li>
      ))}
    </ul>
  )
}
